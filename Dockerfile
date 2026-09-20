FROM jupyter/scipy-notebook:python-3.11
RUN pip install --no-cache-dir sqlalchemy psycopg2-binary
