{
  lib,
  fetchurl,
}:
final: prev: {
  # A tool to convert HomeBank files to Ledger format
  AppHomeBank2Ledger = final.buildPerlPackage {
    pname = "App-HomeBank2Ledger";
    version = "0.010";
    src = fetchurl {
      url = "mirror://cpan/authors/id/C/CC/CCM/App-HomeBank2Ledger-0.010.tar.gz";
      hash = "sha256-Jg/qej3+3igJT3mlYU51Z3hh74BexwfOSTlUaElxmKc=";
    };
    propagatedBuildInputs = with final; [
      ModulePluggable
      XMLEntities
      XMLParserLite
    ];
    meta = {
      homepage = "https://github.com/chazmcgarvey/homebank2ledger";
      description = "A tool to convert HomeBank files to Ledger format";
      license = lib.licenses.mit;
      mainProgram = "homebank2ledger";
    };
  };
}
