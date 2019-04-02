# add a base image
FROM lsucrc/crcbase

USER crcuser
WORKDIR /model
# install hypre
RUN curl -kLO https://computation.llnl.gov/projects/hypre-scalable-linear-solvers-multigrid-methods/download/hypre-2.11.2.tar.gz
RUN tar xzf hypre-2.11.2.tar.gz
WORKDIR hypre-2.11.2/src
RUN ./configure && make install

# download nhwave source code and extract it
WORKDIR /model
RUN git clone https://github.com/JimKirby/NHWAVE.git
WORKDIR NHWAVE/src
RUN mv Makefile.supermic.mpif90 Makefile

# remove -C option to avoid generating C comments
RUN sed -i 's/DEF_FLAGS     = -P -C -traditional/            DEF_FLAGS     = -P -traditional/' Makefile 
RUN sed -i 's/FLAG_9 = -DINTEL/      #       FLAG_9 = -DINTEL/' Makefile 
RUN sed -i 's/FLAG_15 = -DFROUDE_CAP/      #       FLAG_15 = -DFROUDE_CAP/' Makefile 
RUN sed -i 's/LIBS  = -L\/worka\/work\/chzhang\/hypre\/parallel\/lib -lHYPRE/      LIBS  = -L\/model\/hypre-2.11.2\/src\/hypre\/lib -lHYPRE/' Makefile 
RUN sed -i 's/INCS  = -L\/worka\/work\/chzhang\/hypre\/parallel\/include/       INCS  = -I\/model\/hypre-2.11.2\/src\/hypre\/include/' Makefile 

# compile nvwave
RUN make clean && make

# set up enviroment variable of nhwave
ENV PATH $PATH:/model/NHWAVE/src
RUN chmod +rx /model/NHWAVE/src/nhwave


