"""
Applet: DadJokes
Summary: Displays dad jokes
Description: Displays a random dad joke from icanhazdadjoke.com.
Author: tiecia
"""

load("render.star", "render")
load("schema.star", "schema")
load("http.star", "http")
load("cache.star", "cache")

JOKES_API_URL = "https://icanhazdadjoke.com/"
MIN_DISPLAY_TIME = 15000
MAX_JOKE_LENGTH = 100

DEFAULT_TEXT_COLOR = "#ffffff"
DEFAULT_REFRESH_INTERVAL = 0
DEFAULT_DELAY = 200
SHORTER_DELAY = 125

#OVER = "I saw an ad in a shop window, \"Television for sale, \\$1, volume stuck on full\", I thought, \"I can't turn that down\"test test test test test test test test test test test test test test test "
MAX_LENGTH_STRING = "I saw an ad in a shop window, \"Television for sale, $1, volume stuck on full\", I thought, \"I can't turn"

def main(config):
    joke = cache.get("joke")

    refresh_interval = config.get("refreshinterval", "0")
    text_color = config.get("textcolor")
    #Validate user input
    if(not refresh_interval.isdigit()):
        refresh_interval = DEFAULT_REFRESH_INTERVAL
    else:
        refresh_interval = int(refresh_interval)

    if(joke == None):
        print("Getting new joke.")
        #GET HTTP request
        params = {
            "accept" : "application/json"
        }
        report = http.get(url=JOKES_API_URL, headers=params)
        if report.status_code != 200:
            fail("API call failed with status %d", report.status_code)

        joke = report.json()["joke"]
        cache.set("joke", joke, ttl_seconds=refresh_interval)
    print(joke)

    #Scroll faster if joke is longer.
    scroll_delay = DEFAULT_DELAY
    if(len(joke) > MAX_JOKE_LENGTH):
        scroll_delay = SHORTER_DELAY
    
    return render.Root(
        delay = scroll_delay,
        child = render.Marquee (
            child = render.WrappedText(
                content = joke,
                #color = text_color,
            ),
            height = 32,
            offset_start = 30,
            offset_end = 60,
            scroll_direction = "vertical",
        )
    )

def get_schema():
    options = [
        schema.Option(
            display = "White",
            value = "#ffffff",
        ),
        schema.Option(
            display = "Blue",
            value = "#001eff",
        ),
        schema.Option(
            display = "Light Blue",
            value = "#00a2ff",
        ),
        schema.Option(
            display = "Red",
            value = "#ff0000",
        ),
        schema.Option(
            display = "Pink",
            value = "#ff00fb",
        ),
        schema.Option(
            display = "Purple",
            value = "#9900ff",
        ),
        schema.Option(
            display = "Green",
            value = "#0dff00",
        ),
        schema.Option(
            display = "Yellow",
            value = "#fbff00",
        ),
    ]
    return schema.Schema(
        version = "1",
        fields = [
            schema.Text(
                id="refreshinterval",
                name="Refresh Interval",
                desc="Interval between getting a new joke (in seconds). Enter 0 to get a new joke each rotation.",
                icon="clock",
            ),
            schema.Dropdown(
                id = "textcolor",
                name = "Text Color",
                desc = "The color of the text to be displayed.",
                icon = "brush",
                default = options[0].value,
                options = options,
            )
        ],
    )