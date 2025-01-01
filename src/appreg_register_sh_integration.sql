BEGIN;
INSERT OR UPDATE INTO mimetypes (ext, mimetype) VALUES ('sh', 'MT:text/x-shellscript');
INSERT OR UPDATE INTO extenstions (ext, mimetype) VALUES ('sh', 'MT:text/x-shellscript');

INSERT OR UPDATE INTO handlerIds (handlerId) VALUES ('com.notmarek.shell_integration.launcher');
INSERT OR UPDATE INTO properties (handlerId, name, value) VALUES ('com.notmarek.shell_integration.launcher', 'extend-start', 'Y');
INSERT OR UPDATE INTO properties (handlerId, name, value) VALUES ('com.notmarek.shell_integration.launcher', 'unloadPolicy', 'unloadOnPause');
INSERT OR UPDATE INTO properties (handlerId, name, value) VALUES ('com.notmarek.shell_integration.launcher', 'maxGoTime', '60');
INSERT OR UPDATE INTO properties (handlerId, name, value) VALUES ('com.notmarek.shell_integration.launcher', 'maxPauseTime', '60');
INSERT OR UPDATE INTO properties (handlerId, name, value) VALUES ('com.notmarek.shell_integration.launcher', 'maxUnloadTime', '60');
INSERT OR UPDATE INTO properties (handlerId, name, value) VALUES ('com.notmarek.shell_integration.launcher', 'maxLoadTime', '60');
INSERT OR UPDATE INTO properties (handlerId, name, value) VALUES ('com.notmarek.shell_integration.launcher', 'command', '/var/local/kmc/bin/sh_integration_launcher');

INSERT OR UPDATE INTO associations (interface, handlerId, contentId, defaultAssoc) VALUES ('extractor', 'com.notmarek.shell_integration.extractor', 'GL:*.sh', 'true');


INSERT OR UPDATE INTO handlerIds (handlerId) VALUES ('com.notmarek.shell_integration.extractor');
INSERT OR UPDATE INTO properties (handlerId, name, value) VALUES ('com.notmarek.shell_integration.extractor', 'lib', '/var/local/kmc/lib/sh_integration_extractor.so');
INSERT OR UPDATE INTO properties (handlerId, name, value) VALUES ('com.notmarek.shell_integration.extractor', 'entry', 'load_extractor');

INSERT OR UPDATE INTO associations (interface, handlerId, contentId, defaultAssoc) VALUES ('application', 'com.notmarek.shell_integration.launcher', 'MT:text/x-shellscript', 'true');
COMMIT;