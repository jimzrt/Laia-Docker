FROM nvidia/cuda:8.0-cudnn5-devel-ubuntu16.04

RUN apt-get update \
  && apt-get install -y \
  git \
  wget \
  sudo \
  gawk \
  libssl-dev \
  libgoogle-glog-dev \
  automake \
  autoconf \
  subversion \
  libatlas3-base \
  vim \
  pkg-config \
  libmagickcore-dev \
  liblapack-dev \
  && apt-get clean \
  && apt-get autoremove \
  && rm -rf /var/lib/apt/lists/*
  
RUN git clone https://github.com/torch/distro.git /root/torch --recursive \
  && cd /root/torch \
  && bash install-deps \
  && ./install.sh -b

# Export environment variables manually
ENV LUA_PATH='/root/.luarocks/share/lua/5.1/?.lua;/root/.luarocks/share/lua/5.1/?/init.lua;/root/torch/install/share/lua/5.1/?.lua;/root/torch/install/share/lua/5.1/?/init.lua;./?.lua;/root/torch/install/share/luajit-2.1.0-beta1/?.lua;/usr/local/share/lua/5.1/?.lua;/usr/local/share/lua/5.1/?/init.lua'
ENV LUA_CPATH='/root/.luarocks/lib/lua/5.1/?.so;/root/torch/install/lib/lua/5.1/?.so;./?.so;/usr/local/lib/lua/5.1/?.so;/usr/local/lib/lua/5.1/loadall.so'
ENV PATH=/root/torch/install/bin:$PATH
ENV LD_LIBRARY_PATH=/root/torch/install/lib:$LD_LIBRARY_PATH
ENV DYLD_LIBRARY_PATH=/root/torch/install/lib:$DYLD_LIBRARY_PATH
ENV LUA_CPATH='/root/torch/install/lib/?.so;'$LUA_CPATH
  
RUN luarocks install http://raw.githubusercontent.com/baidu-research/warp-ctc/master/torch_binding/rocks/warp-ctc-scm-1.rockspec \
  && luarocks install http://raw.githubusercontent.com/jpuigcerver/imgdistort/master/torch/imgdistort-scm-1.rockspec \
  && LIBRARY_PATH=$(echo "$LIBRARY_PATH" | sed 's|^:||; s|:$||; s|::|:|g;') \
  && luarocks install http://raw.githubusercontent.com/jpuigcerver/Laia/master/rocks/laia-scm-1.rockspec \
  && luarocks install lalarm

RUN cd && git clone https://github.com/kaldi-asr/kaldi.git &&  cd kaldi/tools && make -j 4 && cd ../src && ./configure --shared && make depend -j 4 && make -j 4
RUN cd && git clone https://github.com/mauvilsa/imgtxtenh.git && cd imgtxtenh && mkdir -p build && cd build && cmake -DCMAKE_BUILD_TYPE=Release .. && make -j 4
ENV PATH $PATH:/root/kaldi/src/bin:/root/imgtxtenh/build

Run cd && git clone https://github.com/jpuigcerver/Laia.git && cd Laia/egs/spanish-numbers \
  && sed -i 's/wget /wget --no-check-certificate /g' run.sh 
  #&& mkdir -p data/ && wget --no-check-certificate -P data/ https://www.prhlt.upv.es/corpora/spanish-numbers/Spanish_Number_DB.tgz \
  #&& tar -xvzf data/Spanish_Number_DB.tgz -C data
  
WORKDIR "/root"
CMD ["/bin/bash"]
