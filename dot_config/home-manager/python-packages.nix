{ pkgs }:

pkgs.python311.withPackages (p: with p; [
  httpx # async HTTP
  beautifulsoup4 # web scraping
  folium # maps
  geopy # geographical data
  ipython # interactive shell
  matplotlib # plots
  networkx # graphs
  numpy # numerical computation
  pandas # data analysis
  requests # HTTP library
  scapy
  fastapi
  uvicorn
  aiofiles
  sqlalchemy
  asyncpg
  pip
  python-lsp-server
  black
  pynvim
  rope
  flake8
])
