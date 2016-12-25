{ fetchgit,  cmake, stdenv,
  gcc, gfortran, fftw, fftwSinglePrec,
  liblapackWithAtlas, cfitsio, flex, bison,
  wcslib, casacore-data,
  # For the Python wrapper
  python,  boost, numpy
 }:

stdenv.mkDerivation rec {
    name = "casacore";
    buildInputs = [ cmake cfitsio gfortran flex bison liblapackWithAtlas wcslib casacore-data python
    boost numpy ];

 #   src = fetchgit {
#    	url = "https://github.com/casacore/casacore.git" ;
#	rev = "c11f3a68a68bb53535e6a26d885745512a88e9ea" ;
#	sha256 = "1sw0apnmr9xljl26hk9ixam03q5vkdhvmkhhlzbacwz6w65mcpa4";
#	leaveDotGit = false;
#    };

    src = fetchgit {
    	url = "file:///home/bnikolic/oss/casacore/" ;
	rev = "a1d1d61a9f0c072e9ebc9a1510aca3564806ecbd" ;
	sha256 = "041w0bz7jjlhs17n3qfwmvi803yjwpy2g045srb87ymmfkww7366";
	leaveDotGit = false;
    };

    cmakeFlags = [
     "-DCXX11=1"
     "-DDATA_DIR=${casacore-data}/share/casacore-data"
     "-DCMAKE_LIBRARY_PATH=${gfortran}/lib"
     "-DUseCasacoreNamespace=1"
     ];

     enableParallelBuilding = true;

}