<?php
function adminer_object() {
    include_once "./plugins/plugin.php";

    foreach (glob("plugins/*.php") as $filename) {
        include_once "./$filename";
    }

    $plugins = array(
        new AdminerDumpXml(),
        new AdminerTinymce(),
        new AdminerFileUpload("data/"),
        new AdminerSlugify(),
        new AdminerTranslation(),
        new AdminerForeignSystem(),
    );

    return new AdminerPlugin($plugins);
}

include "./adminer.php";
