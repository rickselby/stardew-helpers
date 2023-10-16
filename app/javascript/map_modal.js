document.addEventListener('DOMContentLoaded', function() {
    const mapModal = document.getElementById('map-modal')
    if (mapModal) {
        mapModal.addEventListener('show.bs.modal', event => {
            // Button that triggered the modal
            const button = event.relatedTarget
            const mapPath = button.getAttribute('data-bs-map')
            const modalMap = mapModal.querySelector('img')
            modalMap.src = "/map/" + mapPath
        })
    }
});
