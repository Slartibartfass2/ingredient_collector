function getIngredients(servings) {
    const title = document.getElementsByClassName("kptn-recipetitle")[0].innerText.trim()
    const ingredients = []

    const list = document.getElementsByClassName("col-md-offset-3")[2].children
    // Skip first two html elements which aren't ingredients
    const ingredientList = [].slice.call(list, 2);
    const recipeServings = Number(list[0].children[0].innerText.trim().split(" ")[1])
    const servingsMultiplier = servings / recipeServings

    // Parse each ingredient and store it in the list
    for (const ingredient of ingredientList) {
        let amount = 0
        let unit = ""
        let name = ""

        let nameElement = ingredient.getElementsByClassName("kptn-ingredient")[0]

        if (nameElement !== undefined) {
            name = nameElement.innerText.trim();
        }

        let measureElement = ingredient.getElementsByClassName("kptn-ingredient-measure")[0]

        if (measureElement !== undefined) {
            const amountUnitStrings = measureElement.innerText.trim().split(" ")
            amount = amountUnitStrings[0] * servingsMultiplier

            if (amountUnitStrings.length === 2) {
                unit = amountUnitStrings[1]
            }
        }

        ingredients.push({name: name, amount: amount, unit: unit})
    }
    return {name: title, servings: servings, ingredients: ingredients}
}
