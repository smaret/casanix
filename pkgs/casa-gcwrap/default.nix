{ fetchgit,  fetchsvn, cmake, stdenv, makeWrapper,
  gcc, gfortran, fftw, fftwSinglePrec,
  liblapackWithAtlas, cfitsio, flex, bison,
  wcslib, casacore, boost, xorg, qwt,
  pgplot, libsakura, rpfits,
  swig, blas, gsl, jre,
  dbus, dbus_cplusplus, dbus_tools, xercesc, sqlite, readline, ncurses, python , dbus_libs,
  libxslt,
  # Use pkgconfig to properly find dbus
  pkgconfig, 
  # For potential fetch from SVN
  subversion, subversionClient,
  # Perl is used to create the SO version string
  perl,
  casa, casa-data, casa-asap,
  numpy, matplotlib, scipy, ipython010, dateutil, six, cycler, pyparsing, traitlets, ipython_genutils, decorator,  simplegeneric, jupyter_core, pygments,
  # Run-time dependency (test framework?)
  nose, pexpect, backports_shutil_get_terminal_size, pathlib2, pickleshare, pathpy, prompt_toolkit, wcwidth,
  readlinepython, dbuspython
 }:

# TODO: google test at the moment has to be in tree. Factor out as separate package and make proper dependnecy
stdenv.mkDerivation rec {
    name = "casa-gwcrap";

    buildInputs = [ cmake cfitsio gfortran flex bison liblapackWithAtlas wcslib casacore boost xorg.libXpm qwt
          pgplot libsakura rpfits
	  swig fftw fftwSinglePrec
	  blas gsl jre
  	  dbus dbus_cplusplus dbus_tools xercesc sqlite readline ncurses python dbus_libs
	  pkgconfig libxslt subversion subversionClient perl
	  casa casa-data casa-asap
	  makeWrapper
          ];

    propagatedBuildInputs = [
    numpy matplotlib scipy ipython010 dateutil six cycler pyparsing traitlets ipython_genutils decorator  simplegeneric jupyter_core pygments pexpect pathlib2 pickleshare pathpy prompt_toolkit wcwidth readlinepython
    dbuspython];

    gitrev="b20ad3818aebb1ad47a48e0d62413b75cce561fd";
    src = fetchgit {
    	url = https://open-bitbucket.nrao.edu/scm/casa/casa.git ;
	rev = "${gitrev}" ;
	sha256 = "1bmc4bmlmb7835nc5hg6zckkp6ncw1d4s8pbv5nlviin68ih5vgk";
    };


    # Uses pkgconfig to dbus
    patches = [
        ./buildfix.patch
	./casa1.patch
	./casa3.patch
	./casa4.patch
	./casa5.patch
    ];

    postInstall =  ''
    substituteInPlace $out/python/2.7/casapy.py \
      --replace "@CASADATAROOT@"  ${casa-data} \
      --replace "@CASAGCWRAPROOT@" $out
    # Note @ gets eaten during install so do not use
    for a in $out/bin/casa
    do 
        substituteInPlace  $a\
	      --replace "NIXPYTHON"  ${python} \
              --replace "NIXPGPLOT" ${pgplot} \
              --replace "NIXCASAGCWRAP" $out
	wrapProgram $a \
	   --prefix PYTHONPATH : "$(toPythonPath ${matplotlib}):$(toPythonPath ${numpy}):$(toPythonPath ${scipy}):$(toPythonPath ${ipython010}):$(toPythonPath ${pyparsing}):$(toPythonPath ${jupyter_core}):$(toPythonPath ${cycler}):$(toPythonPath ${simplegeneric}):$(toPythonPath ${six}):$(toPythonPath ${dateutil}):$(toPythonPath ${traitlets}):$(toPythonPath ${decorator}):$(toPythonPath ${ipython_genutils}):$(toPythonPath ${pygments}):$(toPythonPath ${pexpect}):$(toPythonPath ${backports_shutil_get_terminal_size}):$(toPythonPath ${pathlib2}):$(toPythonPath ${pickleshare}):$(toPythonPath ${pathpy}):$(toPythonPath ${prompt_toolkit}):$(toPythonPath ${wcwidth}):$(toPythonPath ${readlinepython}):$(toPythonPath ${dbuspython}):${casa-asap}/python/2.7" \
	   --prefix CASAPATH : "${casa-data}/share"
	   
    done
	      
      '';      

    preConfigure = ''
        export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:${dbus}/lib/pkgconfig"
    '';    

    # Switch to proper fotran path
    cmakeFlags = [
     "-DCMAKE_Fortran_COMPILER=${gfortran}/bin/gfortran"
     "-DNUMPY_ROOT_DIR=${numpy}/lib/python2.7/site-packages/numpy/core"
     ];

    sourceRoot = "casa-b20ad38/gcwrap";
    enableParallelBuilding = true;
}
