{
  description = "The CXXOpts C++ command line parsing library, with unicode support disabled";

  inputs = {
    nixpkgs.url     = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { 
  	self, 
  	nixpkgs, 
  	flake-utils,
  }: flake-utils.lib.eachDefaultSystem
	   (system:
           let
             	pkgs = import nixpkgs { inherit system; };
		          packageName = "cxxopts";
             	version = "3.1.1";
           in {
                packages.${packageName} = pkgs.stdenv.mkDerivation rec {
                  pname = packageName;
                  inherit version;
                
                  src = pkgs.fetchFromGitHub {
                    owner = "jarro2783";
                    repo = "cxxopts";
                    rev = "v${version}";
                    sha256 = "sha256-lJPMaXBfrCeUhhXha5f7zmOGtyEDzU3oPTMirPTFZzQ=";
                  };
                
                  nativeBuildInputs = [ pkgs.cmake ];
                
                  cmakeFlags = [
                    "-DCXXOPTS_USE_UNICODE=OFF"
                    "-DSPDLOG_COMPILED_LIB=OFF"

                  ];
                
                  doCheck = true;

                  # Conflict on case-insensitive filesystems.
                  dontUseCmakeBuildDir = true;

                  # https://github.com/jarro2783/cxxopts/issues/332
                  postPatch = ''
                    substituteInPlace packaging/pkgconfig.pc.in \
                      --replace '$'{prefix}/@CMAKE_INSTALL_INCLUDEDIR@ @CMAKE_INSTALL_FULL_INCLUDEDIR@
                  '';

                  meta = with pkgs.lib; {
                    homepage    = "https://github.com/jarro2783/cxxopts";
                    description = "Lightweight C++ GNU-style option parser library";
                    license     = licenses.mit;
                    maintainers = [ maintainers.spease ];
                    platforms   = platforms.all;
                  };
        	        
        	      };

                defaultPackage = self.packages.${system}.${packageName};
           }
     );
}
