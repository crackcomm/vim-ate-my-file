{ pkgs, pself }:

with pself;
buildPythonPackage rec {
  pname = "trafilatura";
  version = "2.0.0";
  format = "pyproject";

  src = pkgs.fetchFromGitHub {
    owner = "crackcomm";
    repo = pname;
    rev = "bc55b08517861ab1a700e514a5cb93080ddd9b61";
    sha256 = "sha256-xPtPyvhCXvZ4A01MN++Wfhxv93HZYeyhck+ufm/S324=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml --replace 'setuptools>=61.0' 'setuptools'
  '';

  nativeBuildInputs = [ setuptools wheel ];

  propagatedBuildInputs =
    [ certifi charset-normalizer courlan htmldate justext lxml urllib3 flask ];

  meta = {
    description =
      "Python & Command-line tool to gather text and metadata on the Web: Crawling, scraping, extraction, output as CSV, JSON, HTML, MD, TXT, XML.";
    homepage = "";
    license = lib.licenses.asl20;
  };
}
