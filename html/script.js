document.body.style.display = 'none';

window.addEventListener('message', function (event) {
    const data = event.data;

    if (data.type === 'toggle') {
        document.body.style.display = data.display ? 'block' : 'none';
    }

    if (data.type === 'update') {
        document.getElementById('lawmenCount').innerText = data.lawmen ?? 0;
        document.getElementById('medicCount').innerText = data.medics ?? 0;

        const list = document.getElementById('playerList');
        list.innerHTML = '';

        if (Array.isArray(data.players)) {
            data.players.forEach(player => {
                const row = document.createElement('tr');
                row.innerHTML = `
                    <td>${player.id}</td>
                    <td>${player.name}</td>
                    <td>${player.job}</td>
                `;
                list.appendChild(row);
            });
        }
    }
});

document.addEventListener("keydown", function (event) {
    if (event.key === "Escape") {
        fetch(`https://${GetParentResourceName()}/hideUI`, {
            method: 'POST'
        });
    }
});



