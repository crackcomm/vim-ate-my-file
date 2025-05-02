#!/usr/bin/env python3

# TODO: fix `#define` lines in C/C++ files
# TODO: collapse renames with modifications

import os
import subprocess
import argparse
import enum
from dataclasses import dataclass, field
from unidiff import PatchSet, PatchedFile
from pathlib import Path

SOURCE_EXTS = {
    ".atd",
    ".bazel",
    ".BUILD",
    ".bzl",
    ".cc",
    ".cpp",
    ".css",
    ".Dockerfile",
    ".fbs",
    ".go",
    ".h",
    ".html",
    ".js",
    ".jsx",
    ".lua",
    ".ml",
    ".mli",
    ".mjs",
    ".nix",
    ".opam",
    ".proto",
    ".py",
    ".rs",
    ".sh",
    ".sky",
    ".star",
    ".tcc",
    ".thrift",
    ".ts",
    ".tsx",
    ".conf",
}
STEM_INCLUDE = {
    "BUILD",
    ".bazelrc",
    "WORKSPACE",
    "dune",
    "dune-project",
    ".ocamlformat",
}

DEFAULT_CONTEXT = 3
MAX_HUNK_SIZE = 1000
CONTEXT_LINES_HUNK = 10000


class LineType(enum.Enum):
    EMPTY = ""
    ADDED = "+"
    REMOVED = "-"
    CONTEXT = " "
    EXTRA_CONTEXT = "@"
    NO_NEWLINE = "\\"

    def __str__(self):
        return self.value


@dataclass(order=True)
class DiffLine:
    value: str = field(compare=False)
    line_type: LineType = field(compare=False)
    diff_line_no: int = field(compare=True)

    @property
    def is_modified(self):
        return self.line_type in {LineType.ADDED, LineType.REMOVED}

    @property
    def is_extra_context(self):
        return self.line_type == LineType.EXTRA_CONTEXT


@dataclass
class DiffHunk:
    lines: list[DiffLine]

    @property
    def start(self):
        return self.lines[0].diff_line_no

    @property
    def end(self):
        return self.lines[-1].diff_line_no


def is_source_file(path: Path) -> bool:
    return path.suffix in SOURCE_EXTS or path.name in STEM_INCLUDE


def indent_level(line: str) -> int:
    return len(line) - len(line.lstrip(" \t"))


def extract_hunks(lines: list[DiffLine]) -> list[DiffHunk]:
    hunks, hunk = [], []
    for line in lines:
        if line.is_modified:
            hunk.append(line)
        elif hunk:
            hunks.append(DiffHunk(hunk))
            hunk = []
    if hunk:
        hunks.append(DiffHunk(hunk))
    return hunks


def find_extra_context_lines(
    hunks: list[DiffHunk], lines: list[DiffLine], radius: int
) -> set[int]:
    max_line = lines[-1].diff_line_no + 1
    context = set()

    for h in hunks:
        before = range(max(0, h.start - radius), h.start)
        after = range(h.end + 1, min(max_line, h.end + radius + 1))
        context.update(before, after)

    for h in hunks:
        i = h.start
        current_indent = indent_level(lines[i].value)
        for j in reversed(range(i + 1)):
            line = lines[j].value
            if not line:
                continue
            indent = indent_level(line)
            if indent < current_indent:
                context.add(j)
                current_indent = indent
            if indent == 0:
                break
    return context


def show_full_diff(f: PatchedFile):
    print(f"--- {f.path} added")
    for line in f[0]:
        print(str(line.line_type).replace("@", " "), line.value.rstrip())


def summarize_file(f: PatchedFile, context_radius: int, force: bool = False):
    if not force:
        if f.is_rename:
            print(f"--- {f.path} renamed to {f.target_file}")
            return
        if f.is_removed_file:
            print(f"--- {f.path} removed")
            return
        if f.is_added_file:
            show_full_diff(f)
            return
        if not (f.is_modified_file and is_source_file(Path(f.path))):
            return
        if len(f) != 1 or not f[0].is_valid():
            return

    hunk = f[0]
    if hunk.added == 0 and hunk.removed == 0:
        return
    if hunk.added > MAX_HUNK_SIZE or hunk.removed > MAX_HUNK_SIZE:
        print(f"--- {f.path} --- {hunk.added + hunk.removed} lines omitted ---")
        return

    print(f"--- {f.path} @@@@ lines {hunk.source_start} + {hunk.source_length} @@@")

    first_line_no = hunk[0].diff_line_no or 0
    lines = [
        DiffLine(
            value=l.value.rstrip(),
            line_type=LineType(l.line_type),
            diff_line_no=(l.diff_line_no or 0) - first_line_no,
        )
        for l in hunk
        if l.diff_line_no is not None
    ]

    hunks = extract_hunks(lines)
    extra_context_lines = find_extra_context_lines(hunks, lines, context_radius)

    for line in lines:
        if line.diff_line_no in extra_context_lines and not line.is_modified:
            line.line_type = LineType.EXTRA_CONTEXT

    omitted = 0
    for line in lines:
        if (
            not line.is_modified
            and not line.is_extra_context
            or (omitted > 0 and line.value == "")
        ):
            omitted += 1
            continue
        if omitted:
            print(f"--- {omitted} lines omitted ---")
            omitted = 0
        print(str(line.line_type).replace("@", " "), line.value.rstrip())
    if omitted:
        print(f"--- {omitted} lines omitted ---")


def main():
    if wd := os.environ.get("BUILD_WORKING_DIRECTORY"):
        os.chdir(wd)

    parser = argparse.ArgumentParser(description="Summarize a diff from a git commit.")
    parser.add_argument("-r", "--rev", required=True, help="jj revision to diff")
    parser.add_argument(
        "-c", "--context", type=int, default=DEFAULT_CONTEXT, help="context radius"
    )
    parser.add_argument("paths", nargs="*", help="paths to diff")
    args = parser.parse_args()

    raw = subprocess.run(
        [
            "jj",
            "diff",
            "--color=never",
            "--git",
            f"--context={CONTEXT_LINES_HUNK}",
            f"-r={args.rev}",
            *args.paths,
        ],
        capture_output=True,
        text=True,
        check=True,
    ).stdout

    patch_set = PatchSet(raw)
    force = len(patch_set) == 1
    for f in patch_set:
        summarize_file(f, args.context, force)


if __name__ == "__main__":
    main()
