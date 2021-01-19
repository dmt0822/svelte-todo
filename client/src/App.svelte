<script>
    import { crossfade } from 'svelte/transition';
    import { quintOut } from 'svelte/easing';
    import { flip } from 'svelte/animate';

    const hasLocalStorage = window && window.localStorage;
    let items = getFromStorage();
    let input = '';

    function getFromStorage() {
        if (hasLocalStorage) {
            let temp = window.localStorage.getItem('items');
            if (temp) return JSON.parse(temp);
        }
        return [];
    }

    // Event handlers
    function handleAdd(e) {
        if(e.type === 'click' || (e.key && e.key.toLowerCase() === 'enter')) {
            const id = items.length;
            items = [...items, {id, input, complete: false }];
            updateStorage('items', JSON.stringify(items));
            input = '';
        }
    }

    function handleDelete(e, index = 0) {
        let tempArray = items;
        items = [...tempArray.splice(index, 1)];
        updateStorage('items', JSON.stringify(items));
    }

    function handleSelectAll(isComplete) {
        const checkboxes = document.querySelectorAll(`input.${isComplete ? 'complete' : 'incomplete'}`);
        if(checkboxes.length) {
            checkboxes.forEach(box => {
                box.checked = true;
                box.dispatchEvent(new Event('change'));
            });
        }
    }

    function handleClearComplete(e) {
        items = items.filter(item => !item.complete);
        updateStorage('items', JSON.stringify(items));
    }

    function toggle(itemId) {
        let item = items.find(i => i.id === itemId);
        item = Object.assign(item, { complete: !item.complete });
        items[item.id] = item;
        items = [...items];
        updateStorage('items', JSON.stringify(items));
    }

    function updateStorage(key, data) {
        if (hasLocalStorage) {
            window.localStorage.setItem(key, data);
        }
    }

    const [send, receive] = crossfade({
        duration: 500,
        fallback(node, params) {
            const style = getComputedStyle(node);
            const transform = style.transform === 'none' ? '' : style.transform;

            return {
                duration: 600,
                easing: quintOut,
                css: t => `
                    transform: ${transform} scale(${t});
                    opacity: ${t}
                `
            }
        }
    });
</script>

<style>
    body {
        margin: 0;
        padding: 0;
    }

    .container {
        display: flex;
        flex-direction: column;
        width: 100%;
        justify-content: center;
        margin: auto;
    }

    .container.horizontal {
        flex-direction: row;
        margin: 0;
    }

    .section {
        flex-direction: column;
        margin: 1em;
        justify-content: flex-start;
        width: 100%;
    }

    .heading {
        font-size: 1.5em;
        font-weight: 400;
    }

    .action-container {
        display: flex;
        flex-direction: row;
        justify-content: center;
        margin: 1em 0;
    }

    button {
        background: none;
        margin: 0;
        border: none;
        outline: none;
    }

    .form-row-inline {
        display: flex;
        flex-direction: row;
        width: 100%;
        justify-content: center;
        font-size: 1.5em;
    }

    .form-row-inline > button {
        width: 10%;
        flex-basis: 10%;
        margin: 0;
        font-size: inherit;
    }

    .form-row-inline > input {
        width: 90%;
        flex-basis: 90%;
        margin: 0;
    }

    input:focus {
        outline: none;
    }

	ul {
        list-style-type: none;
        padding: 0;
    }

    li {
        display: flex;
        align-items: center;
        margin: 1em 0;
        padding: 0.5em 0;
        overflow: hidden;
    }

    li > input {
        margin: 0 1em 0 4px;
        transform: scale(1.5);
    }

    .strike {
        text-decoration: line-through;
    }

    @media (max-width: 550px) {
        .container.horizontal {
            flex-direction: column;
        }
    }

    @media (max-width: 375px) {
        .action-container {
            flex-direction: column;
        }
    }
</style>

<div class="container">
    <div class="form-row-inline">
        <input
            type="text"
            bind:value={input}
            id="input"
            on:keyup={handleAdd}
            autofocus="true"
            placeholder="What needs done?"
        />
        <button on:click={handleAdd}>+</button>
    </div>
    <div class="action-container">
        <button type="button" on:click="{(e) => handleSelectAll(false)}">
            Complete all
        </button>
        <button type="button" on:click="{(e) => handleSelectAll(true)}">
            Incomplete all
        </button>
        <button type="button" on:click="{(e) => handleClearComplete()}">Clear completed</button>
    </div>
    <div class="container horizontal">
        <div class="section">
            <div class="heading">Todo</div>
            <ul>
                {#each items.filter(item => !item.complete) as item (item.id)}
                    <li
                        id="li-{item.id}"
                        in:receive="{{key:item.id}}"
                        out:send="{{key:item.id}}"
                        animate:flip="{{duration: 200}}">
                        <label>
                            <input
                                type="checkbox"
                                name="checkbox-{item.id}"
                                on:change="{(e) => toggle(item.id)}"
                                class="incomplete"
                            />
                            <span class:strike="{item.complete === true}">{item.input}</span>
                        </label>
                    </li>
                {/each}
            </ul>
        </div>
        <div class="section">
            <div class="heading">Done</div>
            <ul>
                {#each items.filter(item => item.complete) as item (item.id)}
                    <li
                        id="li-{item.id}"
                        in:receive="{{key:item.id}}"
                        out:send="{{key:item.id}}"
                        animate:flip="{{duration: 200}}"
                    >
                        <label>
                            <input
                                type="checkbox"
                                name="checkbox-{item.id}"
                                on:change="{(e) => toggle(item.id)}"
                                class="complete"
                            />
                            <span class:strike="{item.complete === true}">{item.input}</span>
                        </label>
                    </li>
                {/each}
            </ul>
        </div>
    </div>
</div>