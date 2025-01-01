BEGIN;
DELETE FROM properties WHERE handlerId='com.notmarek.shell_integration.launcher';
DELETE FROM properties WHERE handlerId='com.notmarek.shell_integration.extractor';
DELETE FROM mimetypes WHERE ext='sh';
DELETE FROM extenstions WHERE ext='sh';
DELETE FROM handlerIds WHERE handlerId='com.notmarek.shell_integration.launcher';
DELETE FROM handlerIds WHERE handlerId='com.notmarek.shell_integration.extractor';
DELETE FROM associations WHERE handlerId='com.notmarek.shell_integration.launcher';

INSERT mimetypes (ext, mimetype) VALUES ('sh', 'MT:text/x-shellscript');
INSERT extenstions (ext, mimetype) VALUES ('sh', 'MT:text/x-shellscript');

INSERT handlerIds (handlerId) VALUES ('com.notmarek.shell_integration.launcher');
INSERT properties (handlerId, name, value) VALUES ('com.notmarek.shell_integration.launcher', 'extend-start', 'Y');
INSERT properties (handlerId, name, value) VALUES ('com.notmarek.shell_integration.launcher', 'unloadPolicy', 'unloadOnPause');
INSERT properties (handlerId, name, value) VALUES ('com.notmarek.shell_integration.launcher', 'maxGoTime', '60');
INSERT properties (handlerId, name, value) VALUES ('com.notmarek.shell_integration.launcher', 'maxPauseTime', '60');
INSERT properties (handlerId, name, value) VALUES ('com.notmarek.shell_integration.launcher', 'maxUnloadTime', '60');
INSERT properties (handlerId, name, value) VALUES ('com.notmarek.shell_integration.launcher', 'maxLoadTime', '60');
INSERT properties (handlerId, name, value) VALUES ('com.notmarek.shell_integration.launcher', 'command', '/var/local/kmc/sh_integration_launcher');

INSERT associations (interface, handlerId, contentId, defaultAssoc) VALUES ('extractor', 'com.notmarek.shell_integration.extractor', 'GL:*.sh', 'true');


INSERT handlerIds (handlerId) VALUES ('com.notmarek.shell_integration.extractor');
INSERT properties (handlerId, name, value) VALUES ('com.notmarek.shell_integration.extractor', 'lib', '/var/local/kmc/sh_integration_extractor.so');
INSERT properties (handlerId, name, value) VALUES ('com.notmarek.shell_integration.extractor', 'entry', 'load_extractor');

INSERT associations (interface, handlerId, contentId, defaultAssoc) VALUES ('application', 'com.notmarek.shell_integration.launcher', 'MT:text/x-shellscript', 'true');
COMMIT;