FROM node:12.13.0
LABEL Rizky Syazuli <br4inwash3r@gmail.com>

# ember server on port 4200
# livereload server on port 7020 (changed in v2.17.0 from 49153)
# test server on port 7357
EXPOSE 4200 7020 7357
WORKDIR /myapp

# run ember server on container start
CMD ["ember", "server"]

# install build dependencies 
RUN \ 
    apt-get update -y && \
    apt-get install -y sudo python-dev vim wget fonts-powerline git-flow

# install watchman
# Note: See the README.md to find out how to increase the
# fs.inotify.max_user_watches value so that watchman will 
# work better with ember projects.
RUN \
    git clone https://github.com/facebook/watchman.git &&\
    cd watchman &&\
    git checkout v4.9.0 &&\
    ./autogen.sh &&\
    ./configure &&\
    make &&\
    make install

# install bower
RUN \
    npm install -g bower@1.8.8

# install chrome for default testem config (as of ember-cli 2.15.0)
RUN \
    apt-get update &&\
    apt-get install -y \
        apt-transport-https \
        gnupg \
        --no-install-recommends &&\
    curl -sSL https://dl.google.com/linux/linux_signing_key.pub | apt-key add - &&\
    echo "deb [arch=amd64] https://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list &&\
    apt-get update &&\
    apt-get install -y \
        google-chrome-stable \
        --no-install-recommends

# tweak chrome to run with --no-sandbox option
RUN \
    sed -i 's/"$@"/--no-sandbox "$@"/g' /opt/google/chrome/google-chrome

# set container bash prompt color to blue in order to 
# differentiate container terminal sessions from host 
# terminal sessions
RUN \
    echo 'PS1="\[\\e[0;94m\]${debian_chroot:+($debian_chroot)}\\u@\\h:\\w\\\\$\[\\e[m\] "' >> ~/.bashrc

# install starship, pretty shell theme for bash
ARG STARSHIP=starship-x86_64-unknown-linux-gnu.tar.gz
RUN \
    wget -q --show-progress https://github.com/starship/starship/releases/latest/download/${STARSHIP} && \
    tar xvf ${STARSHIP} && rm ${STARSHIP} && \
    sudo mv starship /usr/local/bin/ && \
    echo 'eval "$(starship init bash)"' >> ~/.bashrc

# install ember-cli
RUN \
    npm install -g ember-cli@3.14.0
