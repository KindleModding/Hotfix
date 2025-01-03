BEGIN;
DELETE FROM properties WHERE handlerId='org.kindlemodding.hotfix_launcher'
DELETE FROM mimetypes WHERE ext='run_hotfix';
DELETE FROM extenstions WHERE ext='run_hotfix';
DELETE FROM handlerIds WHERE handlerId='org.kindlemodding.hotfix_launcher';
DELETE FROM associations WHERE handlerId='org.kindlemodding.hotfix_launcher';

INSERT INTO mimetypes (ext, mimetype) VALUES ('run_hotfix', 'MT:kindlemodding/run_hotfix');
INSERT INTO extenstions (ext, mimetype) VALUES ('run_hotfix', 'MT:kindlemodding/run_hotfix');

INSERT INTO associations (interface, handlerId, contentId, defaultAssoc) VALUES ('extractor', 'com.lab126.generic.extractor', 'GL:*.run_hotfix', 'true');

INSERT INTO handlerIds (handlerId) VALUES ('org.kindlemodding.hotfix_launcher');
INSERT INTO properties (handlerId, name, value) VALUES ('org.kindlemodding.hotfix_launcher', 'extend-start', 'Y');
INSERT INTO properties (handlerId, name, value) VALUES ('org.kindlemodding.hotfix_launcher', 'unloadPolicy', 'unloadOnPause');
INSERT INTO properties (handlerId, name, value) VALUES ('org.kindlemodding.hotfix_launcher', 'maxGoTime', '600');
INSERT INTO properties (handlerId, name, value) VALUES ('org.kindlemodding.hotfix_launcher', 'maxPauseTime', '600');
INSERT INTO properties (handlerId, name, value) VALUES ('org.kindlemodding.hotfix_launcher', 'maxUnloadTime', '600');
INSERT INTO properties (handlerId, name, value) VALUES ('org.kindlemodding.hotfix_launcher', 'maxLoadTime', '600');
INSERT INTO properties (handlerId, name, value) VALUES ('org.kindlemodding.hotfix_launcher', 'command', '/bin/sh /var/local/kmc/hotfix/run_hotfix.sh');

INSERT INTO associations (interface, handlerId, contentId, defaultAssoc) VALUES ('application', 'org.kindlemodding.hotfix_launcher', 'MT:kindlemodding/run_hotfix', 'true');


COMMIT;