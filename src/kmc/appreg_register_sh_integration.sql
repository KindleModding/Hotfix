BEGIN;
DELETE FROM properties WHERE handlerId='com.notmarek.shell_integration.launcher';
DELETE FROM properties WHERE handlerId='com.notmarek.shell_integration.extractor';
DELETE FROM mimetypes WHERE ext='sh';
DELETE FROM extenstions WHERE ext='sh';
DELETE FROM handlerIds WHERE handlerId='com.notmarek.shell_integration.launcher';
DELETE FROM handlerIds WHERE handlerId='com.notmarek.shell_integration.extractor';
DELETE FROM associations WHERE handlerId='com.notmarek.shell_integration.launcher';

INSERT INTO mimetypes (ext, mimetype) VALUES ('sh', 'MT:text/x-shellscript');
INSERT INTO extenstions (ext, mimetype) VALUES ('sh', 'MT:text/x-shellscript');

INSERT INTO handlerIds (handlerId) VALUES ('com.notmarek.shell_integration.launcher');
INSERT INTO properties (handlerId, name, value) VALUES ('com.notmarek.shell_integration.launcher', 'extend-start', 'Y');
INSERT INTO properties (handlerId, name, value) VALUES ('com.notmarek.shell_integration.launcher', 'unloadPolicy', 'unloadOnPause');
INSERT INTO properties (handlerId, name, value) VALUES ('com.notmarek.shell_integration.launcher', 'maxGoTime', '60');
INSERT INTO properties (handlerId, name, value) VALUES ('com.notmarek.shell_integration.launcher', 'maxPauseTime', '60');
INSERT INTO properties (handlerId, name, value) VALUES ('com.notmarek.shell_integration.launcher', 'maxUnloadTime', '60');
INSERT INTO properties (handlerId, name, value) VALUES ('com.notmarek.shell_integration.launcher', 'maxLoadTime', '60');
INSERT INTO properties (handlerId, name, value) VALUES ('com.notmarek.shell_integration.launcher', 'command', '/var/local/kmc/bin/sh_integration_launcher');

INSERT INTO associations (interface, handlerId, contentId, defaultAssoc) VALUES ('extractor', 'com.notmarek.shell_integration.extractor', 'GL:*.sh', 'true');


INSERT INTO handlerIds (handlerId) VALUES ('com.notmarek.shell_integration.extractor');
INSERT INTO properties (handlerId, name, value) VALUES ('com.notmarek.shell_integration.extractor', 'lib', '/var/local/kmc/lib/sh_integration_extractor.so');
INSERT INTO properties (handlerId, name, value) VALUES ('com.notmarek.shell_integration.extractor', 'entry', 'load_extractor');

INSERT INTO associations (interface, handlerId, contentId, defaultAssoc) VALUES ('application', 'com.notmarek.shell_integration.launcher', 'MT:text/x-shellscript', 'true');
COMMIT;