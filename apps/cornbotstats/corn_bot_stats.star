"""
Applet: Corn Bot Stats
Summary: Stats for corn discord bot
Description: Statistics viewer for the corn discord bot.
Author: tiecia
"""

load("render.star", "render")
load("schema.star", "schema")
load("http.star", "http")
load("encoding/base64.star", "base64")
load("encoding/json.star", "json")

DEFAULT_WHO = "world"

CORN_API_URI = "https://cornbot.azurewebsites.net"

def main(config):
    fetch_leaderboard()
    # print(json)
    # who = config.str("who", DEFAULT_WHO)
    # message = "Hello, {}!".format(who)
    # return render.Root(
    #     child = render.Column(
    #         children=[
    #             render.Row(
    #                 children=[
    #                     render.Text("1.", color="#757575", font="tom-thumb"),
    #                     render.Text(json[0]["Username"], font="tom-thumb"),
    #                 ],
    #             ),
    #             render.Text(json[1]["Username"], font="tom-thumb"),
    #             render.Text(json[2]["Username"], font="tom-thumb"),
    #         ],
    #     )
    # )

    
    if config.bool("custom"):
        return render.Root(
           child = get_custom_leaderboard(format_title(config), get_custom_users(config), format_guild_id(config))
        )
    else:
        return render.Root(
           child = get_global_leaderboard(format_title(config), 4, format_guild_id(config))
        )

def fetch_leaderboard(guild=None):
    if guild == None:
        res = http.get(CORN_API_URI + "/leaderboards", ttl_seconds=240)
    else:
        res = http.get(CORN_API_URI + "/leaderboards?guild=" + guild, ttl_seconds=240)
        
    if res.status_code != 200:
        fail("Corn API request failed with status %d", res.status_code)

    # for development purposes: check if result was served from cache or not
    if res.headers.get("Tidbyt-Cache-Status") == "HIT":
        print("Hit! Displaying cached data.")
    else:
        print("Miss! Calling Corn API.")
    
    return res.json()

def get_custom_users(config):
    users = []

    for i in range(1, 5):
        user = config.get("user" + str(i))
        if(user != None):
            users.append(json.decode(user)["value"])
    
    return users

def format_guild_id(config):
    guild = config.str("guild")
    if(guild != None and not guild.isdigit()):
        guild = None
    return guild

def format_title(config):
    title = config.str("title")
    if(title == None):
        title = "Corn Standings"
    return title

def get_global_leaderboard(title, count_to_display, guild):
    leaderboard = fetch_leaderboard(guild)
    entries = []
    for i in range(count_to_display):
        if(i == len(leaderboard)): # If more positions are requested then are available
            break

        entries.append(leaderboard[i])

    return get_leaderboard(title, entries)

def get_custom_leaderboard(title, usernames, guild):
    leaderboard = fetch_leaderboard(guild)
    entries = []


    for entry in leaderboard:
        for user in usernames:
            if entry["Username"] == user:
                entries.append(entry)

    return get_leaderboard(title, entries)

def get_leaderboard(title, entries):
    rows = [
        render.Padding(
            child=render.Row(
                main_align="center",
                expanded=True,
                children=[
                    render.Text(title, font="tom-thumb", color="#fbec5d")
                ]
            ),
            pad=1
        )
    ]

    for entry in entries:
        rows.append(render.Row(
            expanded=True,
            children = [
                render.Marquee(
                    width=10,
                    child=render.Text(str(int(entry["LeaderboardPosition"])+1), color="#757575", font="tom-thumb")
                ),
                render.Marquee(
                    width=40,
                    child=render.Text(entry["Username"], font="tom-thumb")
                ),
                render.Row(
                    expanded=True,
                    main_align="end",
                    children=[
                        render.Text(str(int(entry["CornCount"])), font="tom-thumb"),
                    ]
                )
            ]
        ))

    return render.Column(children = rows)

def get_schema():
    return schema.Schema(
        version = "1",
        fields = [
            schema.Text(
                id="title",
                name="Leaderboard Title",
                desc="The text to display above the leaderboard.",
                icon="font",
                default="Corn Standings"
            ),
            schema.Text(
                id="guild",
                name="Guild ID",
                desc="Only get corn data from a specific Discord server.",
                icon="discord"
            ),
            schema.Toggle(
                id="custom",
                name="Custom Leaderboard",
                desc="Display custom shuckers in the leaderboard instead of the top 4 global shuckers. Note: If a username is not in the list they need to shuck some corn, the name should then appear.",
                icon="list",
                default=False
            ),
            schema.Typeahead(
                id="user1",
                name="Username 1",
                desc="Description",
                icon="user",
                handler=user_search,
            ),
            schema.Typeahead(
                id="user2",
                name="Username 2",
                desc="Description",
                icon="user",
                handler=user_search,
            ),
            schema.Typeahead(
                id="user3",
                name="Username 3",
                desc="Description",
                icon="user",
                handler=user_search,
            ),
            schema.Typeahead(
                id="user4",
                name="Username 4",
                desc="Description",
                icon="user",
                handler=user_search,
            )
        ],
    )

def user_search(pattern):
    leaderboard = fetch_leaderboard()
    results = []
    for entry in leaderboard:
        username = entry["Username"]
        if username.startswith(pattern):
            results.append(schema.Option(
                display=username,
                value=username
            ))
    return results
