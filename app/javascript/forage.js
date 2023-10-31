window.handleForageFiles = function() {
    if (!this.files.length) {
        return;
    }
    let reader = new FileReader();

    reader.onload = (e) => {
        const finder = new ForageFinder(e.target.result);

        const data = encodeURIComponent(JSON.stringify(finder.postData()));
        Turbo.visit(`/forage?data=${data}`, { frame: "forage" })
    };

    reader.readAsText(this.files[0]);
}

class ForageFinder {
    #farmType;
    #maps;

    constructor(contents) {
        let xml = (new DOMParser).parseFromString(contents, "text/xml");
        this.#farmType = xml.getElementsByTagName("whichFarm")[0].textContent;
        this.#maps = [];
        this.#findForage(xml);
    }

    postData() {
        return {
            'farmType': this.#farmType,
            'maps': this.#maps
        };
    }

    static #lookFor = [
        16, // Wild Horseradish
        18, // Daffodil
        20, // Leek
        22, // Dandelion
        88, // Coconut
        90, // Cactus Fruit
        257, // Morel
        259, // Fiddlehead Fern
        281, // Chanterelle
        283, // Holly
        372, // Clam
        392, // Nautilus Shell
        393, // Coral
        394, // Rainbow Shell
        396, // Spice Berry
        397, // Sea Urchin
        398, // Grape
        402, // Sweet Pea
        404, // Common Mushroom
        406, // Wild Plum
        408, // Hazelnut
        410, // Blackberry
        420, // Red Mushroom
        414, // Crystal Fruit
        418, // Crocus
        718, // Cockle
        719, // Mussel
        723, // Oyster
    ];

    #findForage(xml) {
        for (const location of xml.querySelectorAll("locations > GameLocation")) {
            let mapName = location.querySelector(":scope > name").textContent,
                forage = [];

            for (const item of location.querySelectorAll("objects > item")) {
                let itemID = parseInt(item.querySelector("parentSheetIndex").textContent),
                    bigCraftable = item.querySelector("bigCraftable").textContent === "true";
                if (ForageFinder.#lookFor.includes(itemID) && !bigCraftable) {
                    let x = item.querySelector("tileLocation > X").textContent,
                        y = item.querySelector("tileLocation > Y").textContent,
                        itemName = item.querySelector("name").textContent;

                    forage.push({"x": x, "y": y, "name": itemName});
                }
            }

            for (const item of location.querySelectorAll("terrainFeatures > item")) {
                let whichForageCrop = item.querySelector("whichForageCrop"),
                    isForageCrop = whichForageCrop ? whichForageCrop.textContent === "1" : false;

                if (isForageCrop) {
                    let x = item.querySelector("key X").textContent,
                        y = item.querySelector("key Y").textContent,
                        itemName = "Spring Onion";

                    forage.push({"x": x, "y": y, "name": itemName});
                }
            }

            if (forage.length > 0) {
                this.#maps.push({
                    'map': mapName,
                    'spots': forage,
                });
            }
        }
    }
}
