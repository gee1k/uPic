- 1. Download the latest [appcast_pre.xml](https://svend.cc/uPic/appcast_pre.xml)
- 2. Get the dmg's Sparkle signature
     
     ```
     Pods/Sparkle/bin/sign_update upic.dmg
     ```
- 3. Fill in the output information to the location of the corresponding version in `appcast_pre.xml`
- 4. Copy the `appcast_pre.xml` content to the `appcast.xml` file.
