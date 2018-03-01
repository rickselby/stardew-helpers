
<div id="input-container" class="row center-block panel" style="display:none;">
    <div class="wood-border">
        <h2>Save File</h2>
        <p>
            Select a save file to check:
            <input type="file" id="file_select" />
        </p>
        <div id="input-advice">
            <p>
                Please use the full save file named with your farmer's name and a 9-digit ID number
                (e.g. <code>Fred_148093307</code>);
                do not use the <code>SaveGameInfo</code> file as it does not contain all the necessary information.
            </p>
            <p>
                Default save file locations are:
            </p>
            <ul>
                <li>Windows: <code>%AppData%\StardewValley\Saves\</code></li>
                <li>Mac OSX &amp; Linux: <code>~/.config/StardewValley/Saves/</code></li>
            </ul>
            <p>
                We do not upload your file; all processing is done on your own machine.
            </p>
        </div>
    </div>
</div>

<div id="artifact-maps" class="row center-block panel" style="display:none;">
    <div class="wood-border">
        <h2>Results</h2>
        <p>
            <strong>Note:</strong>
            The farm maps aren't going to be very useful; they are blank, and won't have your own layout.
            The brains behind <a href="//upload.farm">upload.farm</a> have spent a lot of time working out how to
            generate your actual farm layout, and I'm not about to pick off their work here. It should give you some
            indication of where the artifact spots are.
        </p>
        <div id="out"></div>
    </div>
</div>

<div class="row center-block panel">
    <div class="wood-border">
        <h3>About this app</h3>
        <p>
            Your save file contains the locations of artifact spots for the next day.
            This app reads those artifact spots and displays them.
        </p>
    </div>
</div>
