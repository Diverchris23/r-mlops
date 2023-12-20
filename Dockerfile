FROM rocker/r-ver:4.3.1
# Create a non-root user to run the application
RUN useradd --create-home appuser

ENV RENV_CONFIG_REPOS_OVERRIDE=https://packagemanager.rstudio.com/cran/latest
ENV HOME=/home/appuser
WORKDIR $HOME

RUN apt-get update -qq && apt-get install -y --no-install-recommends \
  libcurl4-openssl-dev \
  libicu-dev \
  libsodium-dev \
  libssl-dev \
  make \
  zlib1g-dev \
  && apt-get clean

COPY vetiver_renv.lock renv.lock
# Create the .cache directory and give appuser permission to write to it
RUN mkdir -p /home/appuser/.cache && chown -R appuser:appuser /home/appuser/.cache
# Create the .cache/pins/url directory and give appuser permission to write to it
RUN mkdir -p /home/appuser/.cache/pins/url && chown -R appuser:appuser /home/appuser/.cache/pins/url

RUN Rscript -e "install.packages('renv')"
RUN Rscript -e "renv::restore()"
COPY plumber.R /opt/ml/plumber.R
EXPOSE 7860
ENTRYPOINT ["R", "-e", "pr <- plumber::plumb('/opt/ml/plumber.R'); pr$run(host = '0.0.0.0', port = 7860)"]