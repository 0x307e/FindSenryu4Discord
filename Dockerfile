FROM ruby:2.6.4
# MeCab
WORKDIR /mecab/
RUN curl -L -o mecab-0.996.tar.gz "https://drive.google.com/uc?export=download&id=0B4y35FiV1wh7cENtOXlicTFaRUE" \
  && tar zxfv mecab-0.996.tar.gz \
  && rm mecab-0.996.tar.gz \
  && cd mecab-0.996 \
  && ./configure \
  && make \
  && make check \
  && make install
RUN ldconfig
RUN curl -L -o mecab-ipadic-2.7.0-20070801.tar.gz "https://drive.google.com/uc?export=download&id=0B4y35FiV1wh7MWVlSDBCSXZMTXM" \
  && tar zxfv mecab-ipadic-2.7.0-20070801.tar.gz \
  && rm mecab-ipadic-2.7.0-20070801.tar.gz \
  && cd mecab-ipadic-2.7.0-20070801 \
  && ./configure --with-charset=utf8 \
  && make \
  && make install
RUN ldconfig
WORKDIR /mecab/neologd
RUN git clone --depth 1 https://github.com/neologd/mecab-ipadic-neologd.git /mecab/neologd \
  && ./bin/install-mecab-ipadic-neologd -n -y \
  && sed -i -e 's/ipadic/mecab-ipadic-neologd/g' /usr/local/etc/mecabrc

# Ruby
WORKDIR /app
COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
RUN bundle install
COPY . /app
CMD bundle exec ruby -Ku bot.rb
