function createSidebar() {
    const sidebar = document.getElementById('sidebar');
    sidebar.innerHTML = ''; // Limpia el contenido previo

    const counts = [
        { id: 'lawmenCount', label: '🛡️ Ley' },
        { id: 'medicCount', label: '💉 Doc ' }
    ];

    counts.forEach(item => {
        const container = document.createElement('div');
        container.classList.add('duty-count');

        const value = document.createElement('span');
        value.classList.add('value');
        value.id = item.id;
        value.textContent = '0';

        const label = document.createElement('span');
        label.classList.add('label');
        label.textContent = item.label;

        container.appendChild(value);
        container.appendChild(label);
        sidebar.appendChild(container);
    });
}

// Crear sidebar desde el inicio
createSidebar();

document.getElementById('scoreboard').style.display = 'none';
window.addEventListener('message', function (event) {
    const data = event.data;

    if (data.type === 'toggle') {
        document.getElementById('scoreboard').style.display = data.display ? 'block' : 'none';
    }
    if (data.type === 'update') {
        // Actualizar lista de jugadores
        const list = document.getElementById('playerList');
        const header = document.getElementById('playerTableHeader');
        const title = document.getElementById('scoreboardTitle');
        const totalDisplay = document.getElementById('playerTotal');
        // Actualizar valores
        document.getElementById('lawmenCount').innerText = data.lawmen ?? 0;
        document.getElementById('medicCount').innerText = data.medics ?? 0;
        const isAdmin = data.viewerPerms?.isAdmin === true;
        const canViewJobs = data.viewerPerms?.canViewJobs === true && data.viewerPerms?.isOnDuty === true || isAdmin;

        title.innerText = canViewJobs
            ? data.msg.title[0] + (isAdmin && data.msg.roleName ? ` (${data.msg.roleName})` : '')
            : data.msg.title[1];
        list.innerHTML = '';
        totalDisplay.innerHTML = '';
        if (canViewJobs && Array.isArray(data.players)) {
            header.style.display = '';
            data.players.forEach(player => {
                const row = document.createElement('tr');
                row.innerHTML = `
                    <td>${player.id}</td>
                    <td>${player.name}</td>
                    <td>${player.job}</td>
                `;
                list.appendChild(row);
            });
        } else {
            header.style.display = 'none';
            const row = document.createElement('tr');
            const randomMsg = data.msg.no[Math.floor(Math.random() * data.msg.no.length)];
    
            row.innerHTML = `
                <td colspan="3" class="permission-warning">
                    ${randomMsg}
                </td>
            `;
            list.appendChild(row);
        }
        totalDisplay.innerHTML = `${data.msg.online}: <td>${data.total ?? 0}</td>`;
    }
});

// Escuchar teclas Escape o Backspace para cerrar
document.addEventListener("keydown", function (event) {
    if (event.key === "Escape" || event.key === "Backspace") {
        fetch(`https://${GetParentResourceName()}/hideUI`, {
            method: 'POST'
        });
    }
});