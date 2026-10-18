window.addEventListener("message", (event) => {
    const { action, items, shopItems, sellItems, currency } = event.data;

    if (currency) currentCurrency = currency;

    if (action === "open") {
        const app = document.getElementById("app");
        const sellApp = document.getElementById("sell-app");
        const offerApp = document.getElementById("offer-app");
        const subtitle = document.getElementById("header-subtitle");

        if (app) app.classList.remove("hidden");
        if (sellApp) sellApp.classList.add("hidden");
        if (offerApp) offerApp.classList.add("hidden");
        
        document.body.classList.add("opacity-100", "pointer-events-auto");
        document.body.classList.remove("opacity-0", "pointer-events-none");
        
        if (subtitle) subtitle.innerText = "Console Workshop";
        
        renderItems(items, "craft");
    }

    if (action === "openShop") {
        const app = document.getElementById("app");
        const sellApp = document.getElementById("sell-app");
        const offerApp = document.getElementById("offer-app");
        const subtitle = document.getElementById("header-subtitle");

        if (app) app.classList.remove("hidden");
        if (sellApp) sellApp.classList.add("hidden");
        if (offerApp) offerApp.classList.add("hidden");

        document.body.classList.add("opacity-100", "pointer-events-auto");
        document.body.classList.remove("opacity-0", "pointer-events-none");
        
        if (subtitle) subtitle.innerText = "Console Components";
        
        renderItems(shopItems, "shop");
    }

    if (action === "openSell") {
        const app = document.getElementById("app");
        const sellApp = document.getElementById("sell-app");
        const offerApp = document.getElementById("offer-app");
        
        if (app) app.classList.add("hidden");
        if (sellApp) sellApp.classList.remove("hidden");
        if (offerApp) offerApp.classList.add("hidden");
        
        document.body.classList.add("opacity-100", "pointer-events-auto");
        document.body.classList.remove("opacity-0", "pointer-events-none");
        renderSellItems(sellItems);
    }

    if (action === "showOffer") {
        const sellApp = document.getElementById("sell-app");
        const offerApp = document.getElementById("offer-app");
        
        if (sellApp) sellApp.classList.add("hidden");
        if (offerApp) offerApp.classList.remove("hidden");

        const { price, count, label } = event.data;
        document.getElementById("offer-price").innerText = `${price}`;
        document.getElementById("accept-price").innerText = `${price}`;
        document.getElementById("offer-count").innerText = `${count} ${label}(s)`;
        document.getElementById("offer-status").innerText = "The customer is interested in your console...";
        
        currentOfferData = { itemName: event.data.itemName, price: price };
    }

    if (action === "close") {
        closeUI();
    }
});

let currentOfferData = null;
let currentCurrency = "€";

const acceptOffer = () => {
    if (!currentOfferData) return;
    fetch(`https://${GetParentResourceName()}/acceptOffer`, {
        method: "POST",
        body: JSON.stringify(currentOfferData),
    });
    closeUI();
};

const declineOffer = () => {
    fetch(`https://${GetParentResourceName()}/declineOffer`, {
        method: "POST",
        body: JSON.stringify({}),
    });
    closeUI();
};

const renderSellItems = (items) => {
    const container = document.getElementById("sell-list");
    container.innerHTML = "";

    items.forEach(item => {
        const div = document.createElement("div");
        div.className = "flex-shrink-0 w-40 h-full bg-white rounded-2xl p-4 flex flex-col items-center text-center justify-between group border border-console-pink/10";
        
        div.innerHTML = `
            <div class="w-20 h-20 bg-console-light rounded-xl flex items-center justify-center mb-2 shadow-sm">
                <img src="nui://ox_inventory/web/images/${item.name}.png" class="w-12 h-12 object-contain group-hover:scale-110 transition-transform" alt="${item.label}">
            </div>
            <div class="mb-2">
                <h3 class="text-console-dark font-black text-[10px] uppercase truncate w-32">${item.label}</h3>
                <p class="text-[9px] text-console-pink font-black uppercase mt-0.5">In Stock: ${item.count}</p>
            </div>
            <button onclick="sellItem('${item.name}')" 
                class="w-full py-2 rounded-lg bg-console-pink hover:bg-[#d81b60] text-white text-[9px] font-black uppercase tracking-widest transition-all active:scale-95">
                Select
            </button>
        `;
        container.appendChild(div);
    });
};

const renderItems = (items, type) => {
    const container = document.getElementById("item-list");
    container.innerHTML = "";

    // Reset all quantities to 1 when rendering the list
    for (const key in itemQuantities) delete itemQuantities[key];

    items.forEach((index, itemIdx) => {
        // Items data structure fix: sometimes items come with index as key
        const item = items[itemIdx];
        if (!item) return;

        const div = document.createElement("div");
        div.className = "item-card flex flex-col items-center group";
        div.style.animationDelay = `${itemIdx * 50}ms`;
        
        const buttonLabel = type === "shop" ? "Purchase" : "Craft";
        const buttonAction = type === "shop" ? `buyItem('${item.name}')` : `craftItem('${item.name}')`;
        const priceLabel = type === "shop" ? `<p class="text-console-pink font-black text-xl mb-4">${currentCurrency}${item.price}</p>` : "";

        let ingredientsHtml = "";
        if (type === "craft" && item.ingredients) {
            ingredientsHtml = `
                <div class="w-full mb-4 px-2">
                    <p class="text-[8px] font-black text-console-dark/30 uppercase tracking-[0.2em] mb-2 text-center">Required Materials</p>
                    <div class="flex flex-col gap-1.5">
                        ${item.ingredients.map(ing => `
                            <div class="flex items-center bg-console-pink/20 px-3 py-2 rounded-lg border border-console-pink/10" title="${ing.label || ing.item}">
                                <div class="flex items-center gap-2 flex-1">
                                    <img src="nui://ox_inventory/web/images/${ing.item}.png" class="w-4 h-4 object-contain" onerror="this.src='https://cfx-nui-ox_inventory/web/images/unknown.png'">
                                    <span class="text-[9px] font-black text-console-dark/60 uppercase">${ing.label || ing.item} <span class="text-console-pink ml-1">${ing.amount}x</span></span>
                                </div>
                            </div>
                        `).join('')}
                    </div>
                </div>
            `;
        }

        div.innerHTML = `
            <div class="w-full bg-[#ffe4e9] rounded-[2.5rem] p-6 flex flex-col items-center transition-all duration-500 hover:shadow-xl relative overflow-hidden group border border-console-pink/20">
                <div class="w-full aspect-square rounded-[2rem] bg-white/60 flex items-center justify-center mb-6 relative overflow-hidden">
                    <img src="nui://ox_inventory/web/images/${item.name}.png" class="w-28 h-28 object-contain relative z-10 group-hover:scale-110 transition-transform duration-700" alt="${item.label}">
                </div>
                
                <h3 class="text-console-dark font-black text-[11px] tracking-widest mb-1 text-center uppercase h-8 flex items-center leading-tight px-2">${item.label}</h3>
                ${priceLabel}
                ${ingredientsHtml}
                
                <div class="w-full flex items-center justify-between mb-4 px-2">
                    <button onclick="changeQty('${item.name}', -1)" class="w-10 h-10 rounded-xl bg-white/40 hover:bg-white text-console-pink font-black transition-colors">-</button>
                    <span id="qty-${item.name}" class="text-console-dark font-black text-sm">1</span>
                    <button onclick="changeQty('${item.name}', 1)" class="w-10 h-10 rounded-xl bg-white/40 hover:bg-white text-console-pink font-black transition-colors">+</button>
                </div>
                
                <button onclick="${buttonAction}" 
                    class="w-full py-4 rounded-xl bg-console-pink hover:bg-[#d81b60] text-white text-[10px] font-black uppercase tracking-[0.2em] shadow-lg shadow-pink-500/20 transition-all active:scale-95 flex items-center justify-center gap-2">
                    <span class="text-lg">+</span>
                    ${buttonLabel}
                </button>
            </div>
        `;
        container.appendChild(div);
    });
};

const itemQuantities = {};

const changeQty = (name, change) => {
    if (!itemQuantities[name]) itemQuantities[name] = 1;
    itemQuantities[name] = Math.max(1, Math.min(100, itemQuantities[name] + change));
    const qtyEl = document.getElementById(`qty-${name}`);
    if (qtyEl) qtyEl.innerText = itemQuantities[name];
};

const closeUI = () => {
    fetch(`https://${GetParentResourceName()}/close`, {
        method: "POST",
        body: JSON.stringify({}),
    });
    document.body.classList.add("opacity-0", "pointer-events-none");
    document.body.classList.remove("opacity-100", "pointer-events-auto");
};

const craftItem = (name) => {
    const amount = itemQuantities[name] || 1;
    fetch(`https://${GetParentResourceName()}/craftItem`, {
        method: "POST",
        body: JSON.stringify({ itemName: name, amount: amount }),
    });
    
    // Reset UI quantity to 1
    itemQuantities[name] = 1;
    const qtyEl = document.getElementById(`qty-${name}`);
    if (qtyEl) qtyEl.innerText = "1";
    
    document.body.classList.add("opacity-0", "pointer-events-none");
    document.body.classList.remove("opacity-100", "pointer-events-auto");
};

const sellItem = (name) => {
    fetch(`https://${GetParentResourceName()}/selectItemToSell`, {
        method: "POST",
        body: JSON.stringify({ itemName: name }),
    });
    // We don't close UI here, the client will show the offer UI
};

const buyItem = (name) => {
    const amount = itemQuantities[name] || 1;
    fetch(`https://${GetParentResourceName()}/buyItem`, {
        method: "POST",
        body: JSON.stringify({ itemName: name, amount: amount }),
    });
    
    // Reset UI quantity to 1 after purchase
    itemQuantities[name] = 1;
    const qtyEl = document.getElementById(`qty-${name}`);
    if (qtyEl) qtyEl.innerText = "1";
};

document.addEventListener("keydown", (e) => {
    if (e.key === "Escape") closeUI();
});