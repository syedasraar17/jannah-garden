# Get the game on your Android phone (from your phone)

You need a free GitHub account. GitHub's free cloud computer builds the app (APK) for you. Takes about 10 minutes of setup plus 5-10 minutes of building.

**Android only.** An iPhone cannot install this.

## Steps
1. **Make an account** at github.com (free), then tap **+ → New repository**. Name it `jannah-garden`, leave it **Private** or Public, and tap **Create repository**.
2. **Extract the zip** on your phone with your Files app so you have a normal folder.
3. In the repository tap **Add file → Upload files**. Select **all the files in the folder** (the `.gd`, `.tscn`, `.godot`, `.cfg`, `.md` files, and `.gitignore` if you can see it), then tap **Commit changes**.
   - The hidden `.github` folder usually can't be picked on a phone, so step 4 adds it by hand.
4. Tap **Add file → Create new file**. In the name box type exactly:
   `.github/workflows/build-apk.yml`
   Open `PASTE_THIS_build-apk.yml.txt` from the folder, copy everything, paste it into the big box, and tap **Commit changes**. This starts the build.
5. Tap the **Actions** tab. Open the latest run ("Build Android APK") and wait until it shows a green tick (5-10 minutes).
6. Scroll down to **Artifacts** and tap **JannahGarden-apk** to download it. It arrives as a zip: extract it to get `JannahGarden.apk`.
7. Tap the APK. Android will ask to allow installing from this source (your browser or Files app): allow it, then install. It is a debug-signed app, so Play Protect may warn you. That is normal for apps not from the Play Store.

## Controls on the phone
- Touch the **left side** and drag: move (joystick appears where you touch).
- Drag on the **right side**: look around.
- **Jump**, **Run** (toggle), **Horse** (stand near it to ride, then Jump goes up and Down goes down), and **Ishtiha** (opens the desire menu).

## If the build fails
Open the failed run, tap the red step, and copy the last 20 lines of the message. Send them to me and I'll fix the setup. The first run of a build like this often needs one small fix.

## Notes
- The game was never test-played on a phone from where I wrote it, so expect some rough edges (control sizes, speed on older phones).
- Needs a phone with Vulkan (most phones from about 2018 on). Older or very cheap phones may not run it.
- Shadows are turned off and far objects are hidden on phones to keep it smooth.
