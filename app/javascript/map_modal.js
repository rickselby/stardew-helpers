window.mapModal = function (event) {
    const modalMap = this.querySelector('img');
    modalMap.src = "";
    modalMap.src = "/map/" + event.relatedTarget.getAttribute('data-bs-map');
}
