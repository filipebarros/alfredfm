# alfredfm

Interact with Last.fm using Alfred!

## Usage

1. `alfredfm <username>`
2. Accept the Connect Application request on Last.fm
3. ???
4. **PROFIT**


If this is not working for you, please open an issue so I can track it and correct it!

## Provided Actions

This is a list of all the possible actions to execute using Alfred.fm.

Arguments inside <> are **mandatory**. When not provided, the workflow will not work!

All the arguments inside "" (double quotes) are **optional**. When not provided, it will use the currently playing on **iTunes** information!

### Album
* `albuminfo` - Information about album that is currently playing

### Artist
* `artistinfo "artist` - Fetch information about artist
* `similar "artist"` - Search for similar artists
* `events "artist"` - Searches for events of the artist

### Tracks
* `trackinfo` - Fetches Track Information

### User Related Actions
* `alfredfm <username>` - Allow alfred.fm to access your information. This is necessary to perform the actions in this module! 
* `rartists` - Get your Last.fm recommended actions
* `revents` - Get your Last.fm recommended events
* `friends` - Get a list of all your Last.fm friends
* `loved` - Get a list of all yout Last.fm loved tracks
* `love` - Love the currently playing track
* `ban` - Ban currently playing song
* `tag <tags>` - Tag the currently playing track with tags. If you want to tag with more than one tag, separate the tags with a comma (',')
* `untag <tag>` - Untag the currently playing track with one tag
