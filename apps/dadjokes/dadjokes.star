"""
Applet: DadJokes
Summary: Displays dad jokes
Description: Displays a random dad joke from icanhazdadjoke.com.
Author: tiecia
"""

load("render.star", "render")
load("schema.star", "schema")
load("http.star", "http")

JOKES_API_URL = "https://icanhazdadjoke.com/"

def main(config):
    params = {
        "accept" : "application/json"
    }
    report = http.get(url=JOKES_API_URL, headers=params)
    print("Finding new joke.")
    if report.status_code != 200:
        fail("API call failed with status %d", report.status_code)

    print("New joke found!")
    joke = report.json()["joke"]
    return render.Root(
        delay = 200,
        child = render.Marquee (
            child = render.WrappedText(
                content = joke,
            ),
            height = 32,
            width = 60,
            offset_start = 30,
            offset_end = 50,
            scroll_direction = "vertical",
        )
    )

def get_schema():
    return schema.Schema(
        version = "1",
        fields = [],
    )