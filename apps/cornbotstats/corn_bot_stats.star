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
load("json.star", "json")

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

    
    if(config.bool("custom")):
        return render.Root(
           child = get_custom_leaderboard(config)
        )
    else:
        return render.Root(
           child = get_global_leaderboard(4)
        )

def fetch_leaderboard():
    res = http.get(CORN_API_URI + "/leaderboards", ttl_seconds=240)
    if res.status_code != 200:
        fail("Corn API request failed with status %d", res.status_code)

    # for development purposes: check if result was served from cache or not
    if res.headers.get("Tidbyt-Cache-Status") == "HIT":
        print("Hit! Displaying cached data.")
    else:
        print("Miss! Calling Corn API.")
    
    return res.json()

def get_global_leaderboard(count_to_display):
    leaderboard = fetch_leaderboard()
    entries = []
    for i in range(count_to_display):
        if(i == len(leaderboard)): # If more positions are requested then are available
            break

        entries.append(leaderboard[i])

    return get_leaderboard("Global Corn", entries)

def get_custom_leaderboard(config):
    leaderboard = fetch_leaderboard()
    entries = []
    users = [
        json.decode(config.get("user1")),
        config.get("user2"),
        config.get("user3"),
        config.get("user4")
    ]

    print(users)

    for entry in leaderboard:
        for user in users:
            if entry["Username"] == user:
                entries.append(entry)


    return get_leaderboard("Custom Corn", entries)

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
                render.Text(str(int(entry["LeaderboardPosition"])+1) + " ", color="#757575", font="tom-thumb"),
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
                ),
            ]
        ))

    return render.Column(children = rows)

def get_schema():
    return schema.Schema(
        version = "1",
        fields = [
            schema.Toggle(
                id="custom",
                name="Custom Leaderboard",
                desc="Display custom shuckers in the leaderboard instead of the top 4 global shuckers. Note: If a username is not in the list they need to shuck some corn, the name should then appear.",
                icon="user",
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
        if(username.startswith(pattern)):
            results.append(schema.Option(
                display=username,
                value=username
            ))
    return results

# For future use of Generated fields become more stable
def enable_usernames(custom):
    print("enable_usernames")
    if(custom):
        return [
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
        ]
    else:
        return []