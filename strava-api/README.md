# Strava API + Strava Activities/Streams + PostgreSQL database

Download and analyze Strava activite data via the Strava API. Then send that data into PostgreSQL for processing and analysis. Below are the setup/intall steps, that can also be found in the included python notebook.

1. Install python libraries:
    `pip install jupyter flask psycopg2 requests`
2. Get a postgres database if you don't already have one. On a mac it's as easy as:
    `brew install postgres on a Mac`
3. Get access to a Strava API account https://www.strava.com/settings/api
4. Set up the proper values in [app-config.json](app-config.json) (from steps 1, 2, and 3)
5. Run `python strava.py` at the command line to set up the API Oath token
6. Run the `jupyter-notebook` command and head over to http://localhost:8888/ in your browser and open the [strava_data_api_to_postgres.ipynb](strava_data_api_to_postgres.ipynb)

Once you've done those steps, you can modify the notebook to your liking and download the data you're looking for.
