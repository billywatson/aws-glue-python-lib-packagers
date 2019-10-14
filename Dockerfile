FROM python:3.6

VOLUME /zips

RUN apt-get update \
  && apt-get install -y zip \
  && mkdir /deps \
  && pip install --upgrade pip

WORKDIR /deps

ARG PYTHON_PACKAGE

# export everything before the == as the package name and everything after as the version
# since export only lives for the duration of the container, we're required
# to run all of this as one command
RUN export PYPKG=$(echo "${PYTHON_PACKAGE}" | cut -d '=' -f1) \
  && export PYPKG_VER=$(echo "${PYTHON_PACKAGE}" | sed 's/[^=]*==//') \
  && export PYZIP="${PYPKG}-${PYPKG_VER}.zip" \
  && pip install ${PYTHON_PACKAGE} -t /deps \
  && echo "creating ${PYZIP}" \
  && zip -r9 "/${PYZIP}" *

CMD cp /*.zip /zips/

# Run the following commands to use this.
# docker build -t build_pg8000 .
# docker run --rm --name build_pg8000 -v $PWD/zips:/zips build_pg8000
# Copy this zip file to S3.
# aws s3 cp ./zips/pg8000.zip s3://my-glue-libs/
