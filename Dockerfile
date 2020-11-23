FROM continuumio/miniconda
LABEL org.bokeh.demo.maintainer="Bokeh <info@bokeh.org>"

ENV BK_VERSION=2.2.0
ENV PY_VERSION=3.8
ENV NUM_PROCS=4
ENV BOKEH_RESOURCES=cdn

RUN apt-get install git bash

RUN git clone --branch $BK_VERSION https://github.com/bokeh/bokeh.git /bokeh
RUN git clone https://github.com/spmcelrath/demos.git /demos

RUN mkdir -p /examples && cp -r /bokeh/examples/app /examples/ && rm -rf /bokeh
RUN cp -r /demos/app /examples/ && rm -rf /demos

RUN conda config --append channels bokeh
RUN conda install --yes --quiet python=${PY_VERSION} pyyaml jinja2 bokeh=${BK_VERSION} numpy numba scipy sympy "nodejs>=8.8" pandas scikit-learn bs4 networkx pandas-datareader
RUN conda install -c ranaroussi quantstats
RUN conda clean -ay

# RUN python -c 'import bokeh; bokeh.sampledata.download(progress=False)'
# RUN cd /examples/app/stocks && python download_sample_data.py && cd /

ADD 'index.html' /index.html
ADD 'login.html' /login.html
ADD 'auth.py' /auth.py


EXPOSE 5006
EXPOSE 80

CMD bokeh serve --enable-xsrf-cookies \
    --auth-module=auth.py \
    --disable-index-redirect \
    --allow-websocket-origin="*" \
    --index=/index.html \
    --num-procs=${NUM_PROCS} \
    /examples/app/stock-corrs