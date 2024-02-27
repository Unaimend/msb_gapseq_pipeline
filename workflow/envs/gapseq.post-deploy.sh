R -e 'install.packages("CHNOSZ", repos="http://cran.us.r-project.org")'


wget https://cran.r-project.org/src/contrib/Archive/sybilSBML/sybilSBML_3.1.2.tar.gz 
R CMD INSTALL --configure-args=" \
--with-sbml-include=$CONDA_PREFIX/include \
--with-sbml-lib=$CONDA_PREFIX/lib" sybilSBML_3.1.2.tar.gz
rm sybilSBML_3.1.2.tar.gz
