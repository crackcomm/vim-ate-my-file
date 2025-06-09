{ pself }:

with pself;
buildPythonPackage rec {
  pname = "modal";
  version = "1.0.1";
  format = "pyproject";

  src = fetchPypi {
    inherit pname version;
    sha256 = "06r54clf11s84669ygg04284zf3q1fplf3bysynm6b2n8a1nvxzj";
  };

  postPatch = ''
    substituteInPlace pyproject.toml --replace 'setuptools~=77.0.3' 'setuptools'
  '';

  nativeBuildInputs = [ setuptools wheel ];

  propagatedBuildInputs = [
    aiohttp
    certifi
    click
    grpclib
    protobuf
    rich
    synchronicity
    toml
    typer
    types-certifi
    types-toml
    typing-extensions
    watchfiles
  ];

  meta = {
    description = "Python client library for Modal";
    homepage = "";
    license = lib.licenses.asl20;
  };
}
