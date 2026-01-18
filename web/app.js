let recipes = [];
let categories = {};
let selectedRecipe = null;

const app = document.getElementById('app');
const recipeList = document.getElementById('recipeList');
const itemImage = document.getElementById('itemImage');
const itemCategory = document.getElementById('itemCategory');
const itemLabel = document.getElementById('itemLabel');
const itemDescription = document.getElementById('itemDescription');
const requirementsList = document.getElementById('requirementsList');
const craftBtn = document.getElementById('craftBtn');
const cancelBtn = document.getElementById('cancelBtn');
const closeBtn = document.getElementById('closeBtn');

// 🔒 Hårdlås UI till hidden vid load
function forceHidden() {
    if (!app) return;
    app.classList.add('hidden');
    app.style.display = 'none';
}
forceHidden();

function getItemImagePath(itemName) {
    // ox_inventory item images (default path)
    return `nui://ox_inventory/web/images/${itemName}.png`;
}

function renderRecipes() {
    recipeList.innerHTML = '';

    recipes.forEach(recipe => {
        const el = document.createElement('div');
        el.classList.add('recipe-item');
        el.dataset.id = recipe.id;

        const icon = document.createElement('div');
        icon.classList.add('recipe-icon');

        const img = document.createElement('img');
        img.src = getItemImagePath(recipe.result[0].item);
        img.onerror = () => {
            img.src = 'https://via.placeholder.com/64x64/020617/ffffff?text=?';
        };

        icon.appendChild(img);

        const text = document.createElement('div');
        text.classList.add('recipe-text');

        const label = document.createElement('span');
        label.classList.add('recipe-label');
        label.textContent = recipe.label || recipe.id;

        const cat = document.createElement('span');
        cat.classList.add('recipe-category');
        cat.textContent = (recipe.category || 'misc').toUpperCase();

        text.appendChild(label);
        text.appendChild(cat);

        el.appendChild(icon);
        el.appendChild(text);

        el.addEventListener('click', () => selectRecipe(recipe.id));

        recipeList.appendChild(el);
    });
}

function selectRecipe(id) {
    selectedRecipe = recipes.find(r => r.id === id);
    if (!selectedRecipe) return;

    document.querySelectorAll('.recipe-item').forEach(el => {
        el.classList.toggle('active', el.dataset.id === id);
    });

    const resultItem = selectedRecipe.result[0].item;
    itemImage.src = getItemImagePath(resultItem);
    itemImage.onerror = () => {
        itemImage.src = 'https://via.placeholder.com/128x128/020617/ffffff?text=?';
    };

    const catKey = selectedRecipe.category || 'misc';
    itemCategory.textContent = catKey.toUpperCase();
    itemCategory.style.backgroundColor = categories[catKey] || '#4b5563';

    itemLabel.textContent = selectedRecipe.label || selectedRecipe.id;
    itemDescription.textContent = selectedRecipe.description || '';

    requirementsList.innerHTML = '';
    selectedRecipe.ingredients.forEach(ing => {
        const row = document.createElement('div');
        row.classList.add('requirement-item');

        const name = document.createElement('span');
        name.classList.add('requirement-name');
        name.textContent = ing.label || ing.item;

        const amount = document.createElement('span');
        amount.classList.add('requirement-amount');
        amount.textContent = `x${ing.count}`;

        row.appendChild(name);
        row.appendChild(amount);
        requirementsList.appendChild(row);
    });

    craftBtn.disabled = false;
}

function openUI(data) {
    // 🔐 Extra guard – öppna bara om vi faktiskt fått recept
    if (!data || !data.recipes || !Array.isArray(data.recipes)) return;

    recipes = data.recipes || [];
    categories = data.categories || {};
    selectedRecipe = null;

    app.classList.remove('hidden');
    app.style.display = 'flex';
    craftBtn.disabled = true;

    itemImage.src = '';
    itemCategory.textContent = 'CATEGORY';
    itemCategory.style.backgroundColor = '#4b5563';
    itemLabel.textContent = 'Select a recipe';
    itemDescription.textContent = 'Choose an item from the list to see details.';
    requirementsList.innerHTML = '';

    renderRecipes();
}

function closeUI() {
    forceHidden();
    fetch(`https://${GetParentResourceName()}/close`, {
        method: 'POST',
        body: JSON.stringify({})
    });
}

window.addEventListener('message', (event) => {
    const data = event.data;
    if (!data || !data.action) return;

    if (data.action === 'open') {
        openUI(data);
    } else if (data.action === 'close') {
        closeUI();
    }
});

craftBtn.addEventListener('click', () => {
    if (!selectedRecipe) return;

    fetch(`https://${GetParentResourceName()}/craftItem`, {
        method: 'POST',
        body: JSON.stringify({ recipeId: selectedRecipe.id })
    });
});

cancelBtn.addEventListener('click', closeUI);
closeBtn.addEventListener('click', closeUI);

document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
        closeUI();
    }
});
