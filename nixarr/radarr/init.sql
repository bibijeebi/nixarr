BEGIN TRANSACTION;
CREATE TABLE "AlternativeTitles" ("Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "Title" TEXT NOT NULL, "CleanTitle" TEXT NOT NULL, "SourceType" INTEGER NOT NULL, "MovieMetadataId" INTEGER NOT NULL);
CREATE TABLE "AutoTagging" ("Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "Name" TEXT NOT NULL, "Specifications" TEXT NOT NULL DEFAULT '[]', "RemoveTagsAutomatically" INTEGER NOT NULL DEFAULT 0, "Tags" TEXT NOT NULL DEFAULT '[]');
CREATE TABLE "Blocklist" ("Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "SourceTitle" TEXT NOT NULL, "Quality" TEXT NOT NULL, "Date" DATETIME NOT NULL, "PublishedDate" DATETIME, "Size" INTEGER, "Protocol" INTEGER, "Indexer" TEXT, "Message" TEXT, "TorrentInfoHash" TEXT, "MovieId" INTEGER, "Languages" TEXT NOT NULL, "IndexerFlags" INTEGER NOT NULL);
CREATE TABLE "Collections" ("Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "TmdbId" INTEGER NOT NULL, "QualityProfileId" INTEGER NOT NULL, "RootFolderPath" TEXT NOT NULL, "MinimumAvailability" INTEGER NOT NULL, "SearchOnAdd" INTEGER NOT NULL, "Title" TEXT NOT NULL, "SortTitle" TEXT, "CleanTitle" TEXT NOT NULL, "Overview" TEXT, "Images" TEXT NOT NULL, "Monitored" INTEGER NOT NULL, "LastInfoSync" DATETIME, "Added" DATETIME, "Tags" TEXT);
CREATE TABLE "Commands" ("Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "Name" TEXT NOT NULL, "Body" TEXT NOT NULL, "Priority" INTEGER NOT NULL, "Status" INTEGER NOT NULL, "QueuedAt" DATETIME NOT NULL, "StartedAt" DATETIME, "EndedAt" DATETIME, "Duration" TEXT, "Exception" TEXT, "Trigger" INTEGER NOT NULL, "Result" INTEGER NOT NULL DEFAULT 1);
CREATE TABLE "Config" ("Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "Key" TEXT NOT NULL, "Value" TEXT NOT NULL);
CREATE TABLE "Credits" ("Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "CreditTmdbId" TEXT NOT NULL, "PersonTmdbId" INTEGER NOT NULL, "Name" TEXT NOT NULL, "Images" TEXT NOT NULL, "Character" TEXT, "Order" INTEGER NOT NULL, "Job" TEXT, "Department" TEXT, "Type" INTEGER NOT NULL, "MovieMetadataId" INTEGER NOT NULL);
CREATE TABLE "CustomFilters" ("Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "Type" TEXT NOT NULL, "Label" TEXT NOT NULL, "Filters" TEXT NOT NULL);
CREATE TABLE "CustomFormats" ("Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "Name" TEXT NOT NULL, "Specifications" TEXT NOT NULL, "IncludeCustomFormatWhenRenaming" INTEGER NOT NULL);
CREATE TABLE "DelayProfiles" ("Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "EnableUsenet" INTEGER NOT NULL, "EnableTorrent" INTEGER NOT NULL, "PreferredProtocol" INTEGER NOT NULL, "UsenetDelay" INTEGER NOT NULL, "TorrentDelay" INTEGER NOT NULL, "Order" INTEGER NOT NULL, "Tags" TEXT NOT NULL, "BypassIfHighestQuality" INTEGER NOT NULL DEFAULT 0, "BypassIfAboveCustomFormatScore" INTEGER NOT NULL DEFAULT 0, "MinimumCustomFormatScore" INTEGER);
INSERT INTO "DelayProfiles" VALUES(1,1,1,1,0,0,2147483647,'[]',1,0,NULL);
CREATE TABLE "DownloadClientStatus" ("Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "ProviderId" INTEGER NOT NULL, "InitialFailure" DATETIME, "MostRecentFailure" DATETIME, "EscalationLevel" INTEGER NOT NULL, "DisabledTill" DATETIME);
CREATE TABLE "DownloadClients" ("Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "Enable" INTEGER NOT NULL, "Name" TEXT NOT NULL, "Implementation" TEXT NOT NULL, "Settings" TEXT NOT NULL, "ConfigContract" TEXT NOT NULL, "Priority" INTEGER NOT NULL DEFAULT 1, "RemoveCompletedDownloads" INTEGER NOT NULL DEFAULT 1, "RemoveFailedDownloads" INTEGER NOT NULL DEFAULT 1, "Tags" TEXT);
CREATE TABLE "DownloadHistory" ("Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "EventType" INTEGER NOT NULL, "MovieId" INTEGER NOT NULL, "DownloadId" TEXT NOT NULL, "SourceTitle" TEXT NOT NULL, "Date" DATETIME NOT NULL, "Protocol" INTEGER, "IndexerId" INTEGER, "DownloadClientId" INTEGER, "Release" TEXT, "Data" TEXT);
CREATE TABLE "ExtraFiles" ("Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "MovieId" INTEGER NOT NULL, "MovieFileId" INTEGER NOT NULL, "RelativePath" TEXT NOT NULL, "Extension" TEXT NOT NULL, "Added" DATETIME NOT NULL, "LastUpdated" DATETIME NOT NULL);
CREATE TABLE "History" ("Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "SourceTitle" TEXT NOT NULL, "Date" DATETIME NOT NULL, "Quality" TEXT NOT NULL, "Data" TEXT NOT NULL, "EventType" INTEGER, "DownloadId" TEXT, "MovieId" INTEGER NOT NULL, "Languages" TEXT NOT NULL);
CREATE TABLE "ImportExclusions" ("Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "TmdbId" INTEGER NOT NULL, "MovieTitle" TEXT, "MovieYear" INTEGER DEFAULT 0);
CREATE TABLE "ImportListMovies" ("Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "ListId" INTEGER NOT NULL, "MovieMetadataId" INTEGER NOT NULL);
CREATE TABLE "ImportListStatus" ("Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "ProviderId" INTEGER NOT NULL, "InitialFailure" DATETIME, "MostRecentFailure" DATETIME, "EscalationLevel" INTEGER NOT NULL, "DisabledTill" DATETIME, "LastInfoSync" DATETIME);
CREATE TABLE "ImportLists" ("Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "Enabled" INTEGER NOT NULL, "Name" TEXT NOT NULL, "Implementation" TEXT NOT NULL, "ConfigContract" TEXT, "Settings" TEXT, "EnableAuto" INTEGER NOT NULL, "RootFolderPath" TEXT NOT NULL, "QualityProfileId" INTEGER NOT NULL, "MinimumAvailability" INTEGER NOT NULL, "Tags" TEXT, "SearchOnAdd" INTEGER NOT NULL, "Monitor" INTEGER NOT NULL);
CREATE TABLE "IndexerStatus" ("Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "ProviderId" INTEGER NOT NULL, "InitialFailure" DATETIME, "MostRecentFailure" DATETIME, "EscalationLevel" INTEGER NOT NULL, "DisabledTill" DATETIME, "LastRssSyncReleaseInfo" TEXT, "Cookies" TEXT, "CookiesExpirationDate" DATETIME);
CREATE TABLE "Indexers" ("Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "Name" TEXT NOT NULL, "Implementation" TEXT NOT NULL, "Settings" TEXT, "ConfigContract" TEXT, "EnableRss" INTEGER, "EnableAutomaticSearch" INTEGER, "EnableInteractiveSearch" INTEGER NOT NULL, "Priority" INTEGER NOT NULL DEFAULT 25, "Tags" TEXT, "DownloadClientId" INTEGER NOT NULL DEFAULT 0);
CREATE TABLE "Metadata" ("Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "Enable" INTEGER NOT NULL, "Name" TEXT NOT NULL, "Implementation" TEXT NOT NULL, "Settings" TEXT NOT NULL, "ConfigContract" TEXT NOT NULL);
INSERT INTO "Metadata" VALUES(1,0,'Kodi (XBMC) / Emby','XbmcMetadata','{
  "movieMetadata": true,
  "movieMetadataURL": false,
  "movieMetadataLanguage": 1,
  "movieImages": true,
  "useMovieNfo": false,
  "addCollectionName": true,
  "isValid": true
}','XbmcMetadataSettings');
INSERT INTO "Metadata" VALUES(2,0,'WDTV','WdtvMetadata','{
  "movieMetadata": true,
  "movieImages": true,
  "isValid": true
}','WdtvMetadataSettings');
INSERT INTO "Metadata" VALUES(3,0,'Roksbox','RoksboxMetadata','{
  "movieMetadata": true,
  "movieImages": true,
  "isValid": true
}','RoksboxMetadataSettings');
INSERT INTO "Metadata" VALUES(4,0,'Emby (Legacy)','MediaBrowserMetadata','{
  "movieMetadata": true,
  "isValid": true
}','MediaBrowserMetadataSettings');
CREATE TABLE "MetadataFiles" ("Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "MovieId" INTEGER NOT NULL, "Consumer" TEXT NOT NULL, "Type" INTEGER NOT NULL, "RelativePath" TEXT NOT NULL, "LastUpdated" DATETIME NOT NULL, "MovieFileId" INTEGER, "Hash" TEXT, "Added" DATETIME, "Extension" TEXT NOT NULL);
CREATE TABLE "MovieFiles" ("Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "MovieId" INTEGER NOT NULL, "Quality" TEXT NOT NULL, "Size" INTEGER NOT NULL, "DateAdded" DATETIME NOT NULL, "SceneName" TEXT, "MediaInfo" TEXT, "ReleaseGroup" TEXT, "RelativePath" TEXT, "Edition" TEXT, "Languages" TEXT NOT NULL, "IndexerFlags" INTEGER NOT NULL, "OriginalFilePath" TEXT);
CREATE TABLE "MovieMetadata" ("Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "TmdbId" INTEGER NOT NULL, "ImdbId" TEXT, "Images" TEXT NOT NULL, "Genres" TEXT, "Title" TEXT NOT NULL, "SortTitle" TEXT, "CleanTitle" TEXT, "OriginalTitle" TEXT, "CleanOriginalTitle" TEXT, "OriginalLanguage" INTEGER NOT NULL, "Status" INTEGER NOT NULL, "LastInfoSync" DATETIME, "Runtime" INTEGER NOT NULL, "InCinemas" DATETIME, "PhysicalRelease" DATETIME, "DigitalRelease" DATETIME, "Year" INTEGER, "SecondaryYear" INTEGER, "Ratings" TEXT, "Recommendations" TEXT NOT NULL, "Certification" TEXT, "YouTubeTrailerId" TEXT, "Studio" TEXT, "Overview" TEXT, "Website" TEXT, "Popularity" NUMERIC, "CollectionTmdbId" INTEGER, "CollectionTitle" TEXT);
CREATE TABLE "MovieTranslations" ("Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "Title" TEXT, "CleanTitle" TEXT, "Overview" TEXT, "Language" INTEGER NOT NULL, "MovieMetadataId" INTEGER NOT NULL);
CREATE TABLE "Movies" ("Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "Path" TEXT NOT NULL, "Monitored" INTEGER NOT NULL, "QualityProfileId" INTEGER NOT NULL, "Added" DATETIME, "Tags" TEXT, "AddOptions" TEXT, "MovieFileId" INTEGER NOT NULL, "MinimumAvailability" INTEGER NOT NULL, "MovieMetadataId" INTEGER NOT NULL, "LastSearchTime" DATETIME);
CREATE TABLE "NamingConfig" ("Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "MultiEpisodeStyle" INTEGER NOT NULL, "ReplaceIllegalCharacters" INTEGER NOT NULL, "StandardMovieFormat" TEXT, "MovieFolderFormat" TEXT, "ColonReplacementFormat" INTEGER NOT NULL, "RenameMovies" INTEGER NOT NULL);
INSERT INTO "NamingConfig" VALUES(1,0,1,'{Movie Title} ({Release Year}) {Quality Full}','{Movie Title} ({Release Year})',0,0);
CREATE TABLE "NotificationStatus" ("Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "ProviderId" INTEGER NOT NULL, "InitialFailure" DATETIME, "MostRecentFailure" DATETIME, "EscalationLevel" INTEGER NOT NULL, "DisabledTill" DATETIME);
CREATE TABLE "Notifications" ("Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "Name" TEXT NOT NULL, "OnGrab" INTEGER NOT NULL, "OnDownload" INTEGER NOT NULL, "Settings" TEXT NOT NULL, "Implementation" TEXT NOT NULL, "ConfigContract" TEXT, "OnUpgrade" INTEGER, "Tags" TEXT, "OnRename" INTEGER NOT NULL, "OnHealthIssue" INTEGER NOT NULL, "IncludeHealthWarnings" INTEGER NOT NULL, "OnMovieDelete" INTEGER NOT NULL, "OnMovieFileDelete" INTEGER NOT NULL DEFAULT 0, "OnMovieFileDeleteForUpgrade" INTEGER NOT NULL DEFAULT 0, "OnApplicationUpdate" INTEGER NOT NULL DEFAULT 0, "OnMovieAdded" INTEGER NOT NULL DEFAULT 0, "OnHealthRestored" INTEGER NOT NULL DEFAULT 0, "OnManualInteractionRequired" INTEGER NOT NULL DEFAULT 0);
CREATE TABLE "PendingReleases" ("Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "Title" TEXT NOT NULL, "Added" DATETIME NOT NULL, "Release" TEXT NOT NULL, "MovieId" INTEGER NOT NULL, "ParsedMovieInfo" TEXT, "Reason" INTEGER NOT NULL, "AdditionalInfo" TEXT);
CREATE TABLE "QualityDefinitions" ("Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "Quality" INTEGER NOT NULL, "Title" TEXT NOT NULL, "MinSize" NUMERIC, "MaxSize" NUMERIC, "PreferredSize" NUMERIC);
INSERT INTO "QualityDefinitions" VALUES(1,0,'Unknown',0,100,95);
INSERT INTO "QualityDefinitions" VALUES(2,24,'WORKPRINT',0,100,95);
INSERT INTO "QualityDefinitions" VALUES(3,25,'CAM',0,100,95);
INSERT INTO "QualityDefinitions" VALUES(4,26,'TELESYNC',0,100,95);
INSERT INTO "QualityDefinitions" VALUES(5,27,'TELECINE',0,100,95);
INSERT INTO "QualityDefinitions" VALUES(6,29,'REGIONAL',0,100,95);
INSERT INTO "QualityDefinitions" VALUES(7,28,'DVDSCR',0,100,95);
INSERT INTO "QualityDefinitions" VALUES(8,1,'SDTV',0,100,95);
INSERT INTO "QualityDefinitions" VALUES(9,2,'DVD',0,100,95);
INSERT INTO "QualityDefinitions" VALUES(10,23,'DVD-R',0,100,95);
INSERT INTO "QualityDefinitions" VALUES(11,8,'WEBDL-480p',0,100,95);
INSERT INTO "QualityDefinitions" VALUES(12,12,'WEBRip-480p',0,100,95);
INSERT INTO "QualityDefinitions" VALUES(13,20,'Bluray-480p',0,100,95);
INSERT INTO "QualityDefinitions" VALUES(14,21,'Bluray-576p',0,100,95);
INSERT INTO "QualityDefinitions" VALUES(15,4,'HDTV-720p',0,100,95);
INSERT INTO "QualityDefinitions" VALUES(16,5,'WEBDL-720p',0,100,95);
INSERT INTO "QualityDefinitions" VALUES(17,14,'WEBRip-720p',0,100,95);
INSERT INTO "QualityDefinitions" VALUES(18,6,'Bluray-720p',0,100,95);
INSERT INTO "QualityDefinitions" VALUES(19,9,'HDTV-1080p',0,100,95);
INSERT INTO "QualityDefinitions" VALUES(20,3,'WEBDL-1080p',0,100,95);
INSERT INTO "QualityDefinitions" VALUES(21,15,'WEBRip-1080p',0,100,95);
INSERT INTO "QualityDefinitions" VALUES(22,7,'Bluray-1080p',0,NULL,NULL);
INSERT INTO "QualityDefinitions" VALUES(23,30,'Remux-1080p',0,NULL,NULL);
INSERT INTO "QualityDefinitions" VALUES(24,16,'HDTV-2160p',0,NULL,NULL);
INSERT INTO "QualityDefinitions" VALUES(25,18,'WEBDL-2160p',0,NULL,NULL);
INSERT INTO "QualityDefinitions" VALUES(26,17,'WEBRip-2160p',0,NULL,NULL);
INSERT INTO "QualityDefinitions" VALUES(27,19,'Bluray-2160p',0,NULL,NULL);
INSERT INTO "QualityDefinitions" VALUES(28,31,'Remux-2160p',0,NULL,NULL);
INSERT INTO "QualityDefinitions" VALUES(29,22,'BR-DISK',0,NULL,NULL);
INSERT INTO "QualityDefinitions" VALUES(30,10,'Raw-HD',0,NULL,NULL);
CREATE TABLE "QualityProfiles" ("Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "Name" TEXT NOT NULL, "Cutoff" INTEGER NOT NULL, "Items" TEXT NOT NULL, "Language" INTEGER, "FormatItems" TEXT NOT NULL, "UpgradeAllowed" INTEGER, "MinFormatScore" INTEGER NOT NULL, "CutoffFormatScore" INTEGER NOT NULL, "MinUpgradeFormatScore" INTEGER NOT NULL DEFAULT 1);
INSERT INTO "QualityProfiles" VALUES(1,'Any',20,'[
  {
    "quality": 0,
    "items": [],
    "allowed": false
  },
  {
    "quality": 24,
    "items": [],
    "allowed": true
  },
  {
    "quality": 25,
    "items": [],
    "allowed": true
  },
  {
    "quality": 26,
    "items": [],
    "allowed": true
  },
  {
    "quality": 27,
    "items": [],
    "allowed": true
  },
  {
    "quality": 29,
    "items": [],
    "allowed": true
  },
  {
    "quality": 28,
    "items": [],
    "allowed": true
  },
  {
    "quality": 1,
    "items": [],
    "allowed": true
  },
  {
    "quality": 2,
    "items": [],
    "allowed": true
  },
  {
    "quality": 23,
    "items": [],
    "allowed": true
  },
  {
    "id": 1000,
    "name": "WEB 480p",
    "items": [
      {
        "quality": 8,
        "items": [],
        "allowed": true
      },
      {
        "quality": 12,
        "items": [],
        "allowed": true
      }
    ],
    "allowed": true
  },
  {
    "quality": 20,
    "items": [],
    "allowed": true
  },
  {
    "quality": 21,
    "items": [],
    "allowed": true
  },
  {
    "quality": 4,
    "items": [],
    "allowed": true
  },
  {
    "id": 1001,
    "name": "WEB 720p",
    "items": [
      {
        "quality": 5,
        "items": [],
        "allowed": true
      },
      {
        "quality": 14,
        "items": [],
        "allowed": true
      }
    ],
    "allowed": true
  },
  {
    "quality": 6,
    "items": [],
    "allowed": true
  },
  {
    "quality": 9,
    "items": [],
    "allowed": true
  },
  {
    "id": 1002,
    "name": "WEB 1080p",
    "items": [
      {
        "quality": 3,
        "items": [],
        "allowed": true
      },
      {
        "quality": 15,
        "items": [],
        "allowed": true
      }
    ],
    "allowed": true
  },
  {
    "quality": 7,
    "items": [],
    "allowed": true
  },
  {
    "quality": 30,
    "items": [],
    "allowed": true
  },
  {
    "quality": 16,
    "items": [],
    "allowed": true
  },
  {
    "id": 1003,
    "name": "WEB 2160p",
    "items": [
      {
        "quality": 18,
        "items": [],
        "allowed": true
      },
      {
        "quality": 17,
        "items": [],
        "allowed": true
      }
    ],
    "allowed": true
  },
  {
    "quality": 19,
    "items": [],
    "allowed": true
  },
  {
    "quality": 31,
    "items": [],
    "allowed": true
  },
  {
    "quality": 22,
    "items": [],
    "allowed": true
  },
  {
    "quality": 10,
    "items": [],
    "allowed": false
  }
]',1,'[]',0,0,0,1);
INSERT INTO "QualityProfiles" VALUES(2,'SD',20,'[
  {
    "quality": 0,
    "items": [],
    "allowed": false
  },
  {
    "quality": 24,
    "items": [],
    "allowed": true
  },
  {
    "quality": 25,
    "items": [],
    "allowed": true
  },
  {
    "quality": 26,
    "items": [],
    "allowed": true
  },
  {
    "quality": 27,
    "items": [],
    "allowed": true
  },
  {
    "quality": 29,
    "items": [],
    "allowed": true
  },
  {
    "quality": 28,
    "items": [],
    "allowed": true
  },
  {
    "quality": 1,
    "items": [],
    "allowed": true
  },
  {
    "quality": 2,
    "items": [],
    "allowed": true
  },
  {
    "quality": 23,
    "items": [],
    "allowed": false
  },
  {
    "id": 1000,
    "name": "WEB 480p",
    "items": [
      {
        "quality": 8,
        "items": [],
        "allowed": true
      },
      {
        "quality": 12,
        "items": [],
        "allowed": true
      }
    ],
    "allowed": true
  },
  {
    "quality": 20,
    "items": [],
    "allowed": true
  },
  {
    "quality": 21,
    "items": [],
    "allowed": true
  },
  {
    "quality": 4,
    "items": [],
    "allowed": false
  },
  {
    "id": 1001,
    "name": "WEB 720p",
    "items": [
      {
        "quality": 5,
        "items": [],
        "allowed": false
      },
      {
        "quality": 14,
        "items": [],
        "allowed": false
      }
    ],
    "allowed": false
  },
  {
    "quality": 6,
    "items": [],
    "allowed": false
  },
  {
    "quality": 9,
    "items": [],
    "allowed": false
  },
  {
    "id": 1002,
    "name": "WEB 1080p",
    "items": [
      {
        "quality": 3,
        "items": [],
        "allowed": false
      },
      {
        "quality": 15,
        "items": [],
        "allowed": false
      }
    ],
    "allowed": false
  },
  {
    "quality": 7,
    "items": [],
    "allowed": false
  },
  {
    "quality": 30,
    "items": [],
    "allowed": false
  },
  {
    "quality": 16,
    "items": [],
    "allowed": false
  },
  {
    "id": 1003,
    "name": "WEB 2160p",
    "items": [
      {
        "quality": 18,
        "items": [],
        "allowed": false
      },
      {
        "quality": 17,
        "items": [],
        "allowed": false
      }
    ],
    "allowed": false
  },
  {
    "quality": 19,
    "items": [],
    "allowed": false
  },
  {
    "quality": 31,
    "items": [],
    "allowed": false
  },
  {
    "quality": 22,
    "items": [],
    "allowed": false
  },
  {
    "quality": 10,
    "items": [],
    "allowed": false
  }
]',1,'[]',0,0,0,1);
INSERT INTO "QualityProfiles" VALUES(3,'HD-720p',6,'[
  {
    "quality": 0,
    "items": [],
    "allowed": false
  },
  {
    "quality": 24,
    "items": [],
    "allowed": false
  },
  {
    "quality": 25,
    "items": [],
    "allowed": false
  },
  {
    "quality": 26,
    "items": [],
    "allowed": false
  },
  {
    "quality": 27,
    "items": [],
    "allowed": false
  },
  {
    "quality": 29,
    "items": [],
    "allowed": false
  },
  {
    "quality": 28,
    "items": [],
    "allowed": false
  },
  {
    "quality": 1,
    "items": [],
    "allowed": false
  },
  {
    "quality": 2,
    "items": [],
    "allowed": false
  },
  {
    "quality": 23,
    "items": [],
    "allowed": false
  },
  {
    "id": 1000,
    "name": "WEB 480p",
    "items": [
      {
        "quality": 8,
        "items": [],
        "allowed": false
      },
      {
        "quality": 12,
        "items": [],
        "allowed": false
      }
    ],
    "allowed": false
  },
  {
    "quality": 20,
    "items": [],
    "allowed": false
  },
  {
    "quality": 21,
    "items": [],
    "allowed": false
  },
  {
    "quality": 4,
    "items": [],
    "allowed": true
  },
  {
    "id": 1001,
    "name": "WEB 720p",
    "items": [
      {
        "quality": 5,
        "items": [],
        "allowed": true
      },
      {
        "quality": 14,
        "items": [],
        "allowed": true
      }
    ],
    "allowed": true
  },
  {
    "quality": 6,
    "items": [],
    "allowed": true
  },
  {
    "quality": 9,
    "items": [],
    "allowed": false
  },
  {
    "id": 1002,
    "name": "WEB 1080p",
    "items": [
      {
        "quality": 3,
        "items": [],
        "allowed": false
      },
      {
        "quality": 15,
        "items": [],
        "allowed": false
      }
    ],
    "allowed": false
  },
  {
    "quality": 7,
    "items": [],
    "allowed": false
  },
  {
    "quality": 30,
    "items": [],
    "allowed": false
  },
  {
    "quality": 16,
    "items": [],
    "allowed": false
  },
  {
    "id": 1003,
    "name": "WEB 2160p",
    "items": [
      {
        "quality": 18,
        "items": [],
        "allowed": false
      },
      {
        "quality": 17,
        "items": [],
        "allowed": false
      }
    ],
    "allowed": false
  },
  {
    "quality": 19,
    "items": [],
    "allowed": false
  },
  {
    "quality": 31,
    "items": [],
    "allowed": false
  },
  {
    "quality": 22,
    "items": [],
    "allowed": false
  },
  {
    "quality": 10,
    "items": [],
    "allowed": false
  }
]',1,'[]',0,0,0,1);
INSERT INTO "QualityProfiles" VALUES(4,'HD-1080p',7,'[
  {
    "quality": 0,
    "items": [],
    "allowed": false
  },
  {
    "quality": 24,
    "items": [],
    "allowed": false
  },
  {
    "quality": 25,
    "items": [],
    "allowed": false
  },
  {
    "quality": 26,
    "items": [],
    "allowed": false
  },
  {
    "quality": 27,
    "items": [],
    "allowed": false
  },
  {
    "quality": 29,
    "items": [],
    "allowed": false
  },
  {
    "quality": 28,
    "items": [],
    "allowed": false
  },
  {
    "quality": 1,
    "items": [],
    "allowed": false
  },
  {
    "quality": 2,
    "items": [],
    "allowed": false
  },
  {
    "quality": 23,
    "items": [],
    "allowed": false
  },
  {
    "id": 1000,
    "name": "WEB 480p",
    "items": [
      {
        "quality": 8,
        "items": [],
        "allowed": false
      },
      {
        "quality": 12,
        "items": [],
        "allowed": false
      }
    ],
    "allowed": false
  },
  {
    "quality": 20,
    "items": [],
    "allowed": false
  },
  {
    "quality": 21,
    "items": [],
    "allowed": false
  },
  {
    "quality": 4,
    "items": [],
    "allowed": false
  },
  {
    "id": 1001,
    "name": "WEB 720p",
    "items": [
      {
        "quality": 5,
        "items": [],
        "allowed": false
      },
      {
        "quality": 14,
        "items": [],
        "allowed": false
      }
    ],
    "allowed": false
  },
  {
    "quality": 6,
    "items": [],
    "allowed": false
  },
  {
    "quality": 9,
    "items": [],
    "allowed": true
  },
  {
    "id": 1002,
    "name": "WEB 1080p",
    "items": [
      {
        "quality": 3,
        "items": [],
        "allowed": true
      },
      {
        "quality": 15,
        "items": [],
        "allowed": true
      }
    ],
    "allowed": true
  },
  {
    "quality": 7,
    "items": [],
    "allowed": true
  },
  {
    "quality": 30,
    "items": [],
    "allowed": true
  },
  {
    "quality": 16,
    "items": [],
    "allowed": false
  },
  {
    "id": 1003,
    "name": "WEB 2160p",
    "items": [
      {
        "quality": 18,
        "items": [],
        "allowed": false
      },
      {
        "quality": 17,
        "items": [],
        "allowed": false
      }
    ],
    "allowed": false
  },
  {
    "quality": 19,
    "items": [],
    "allowed": false
  },
  {
    "quality": 31,
    "items": [],
    "allowed": false
  },
  {
    "quality": 22,
    "items": [],
    "allowed": false
  },
  {
    "quality": 10,
    "items": [],
    "allowed": false
  }
]',1,'[]',0,0,0,1);
INSERT INTO "QualityProfiles" VALUES(5,'Ultra-HD',31,'[
  {
    "quality": 0,
    "items": [],
    "allowed": false
  },
  {
    "quality": 24,
    "items": [],
    "allowed": false
  },
  {
    "quality": 25,
    "items": [],
    "allowed": false
  },
  {
    "quality": 26,
    "items": [],
    "allowed": false
  },
  {
    "quality": 27,
    "items": [],
    "allowed": false
  },
  {
    "quality": 29,
    "items": [],
    "allowed": false
  },
  {
    "quality": 28,
    "items": [],
    "allowed": false
  },
  {
    "quality": 1,
    "items": [],
    "allowed": false
  },
  {
    "quality": 2,
    "items": [],
    "allowed": false
  },
  {
    "quality": 23,
    "items": [],
    "allowed": false
  },
  {
    "id": 1000,
    "name": "WEB 480p",
    "items": [
      {
        "quality": 8,
        "items": [],
        "allowed": false
      },
      {
        "quality": 12,
        "items": [],
        "allowed": false
      }
    ],
    "allowed": false
  },
  {
    "quality": 20,
    "items": [],
    "allowed": false
  },
  {
    "quality": 21,
    "items": [],
    "allowed": false
  },
  {
    "quality": 4,
    "items": [],
    "allowed": false
  },
  {
    "id": 1001,
    "name": "WEB 720p",
    "items": [
      {
        "quality": 5,
        "items": [],
        "allowed": false
      },
      {
        "quality": 14,
        "items": [],
        "allowed": false
      }
    ],
    "allowed": false
  },
  {
    "quality": 6,
    "items": [],
    "allowed": false
  },
  {
    "quality": 9,
    "items": [],
    "allowed": false
  },
  {
    "id": 1002,
    "name": "WEB 1080p",
    "items": [
      {
        "quality": 3,
        "items": [],
        "allowed": false
      },
      {
        "quality": 15,
        "items": [],
        "allowed": false
      }
    ],
    "allowed": false
  },
  {
    "quality": 7,
    "items": [],
    "allowed": false
  },
  {
    "quality": 30,
    "items": [],
    "allowed": false
  },
  {
    "quality": 16,
    "items": [],
    "allowed": true
  },
  {
    "id": 1003,
    "name": "WEB 2160p",
    "items": [
      {
        "quality": 18,
        "items": [],
        "allowed": true
      },
      {
        "quality": 17,
        "items": [],
        "allowed": true
      }
    ],
    "allowed": true
  },
  {
    "quality": 19,
    "items": [],
    "allowed": true
  },
  {
    "quality": 31,
    "items": [],
    "allowed": true
  },
  {
    "quality": 22,
    "items": [],
    "allowed": false
  },
  {
    "quality": 10,
    "items": [],
    "allowed": false
  }
]',1,'[]',0,0,0,1);
INSERT INTO "QualityProfiles" VALUES(6,'HD - 720p/1080p',6,'[
  {
    "quality": 0,
    "items": [],
    "allowed": false
  },
  {
    "quality": 24,
    "items": [],
    "allowed": false
  },
  {
    "quality": 25,
    "items": [],
    "allowed": false
  },
  {
    "quality": 26,
    "items": [],
    "allowed": false
  },
  {
    "quality": 27,
    "items": [],
    "allowed": false
  },
  {
    "quality": 29,
    "items": [],
    "allowed": false
  },
  {
    "quality": 28,
    "items": [],
    "allowed": false
  },
  {
    "quality": 1,
    "items": [],
    "allowed": false
  },
  {
    "quality": 2,
    "items": [],
    "allowed": false
  },
  {
    "quality": 23,
    "items": [],
    "allowed": false
  },
  {
    "id": 1000,
    "name": "WEB 480p",
    "items": [
      {
        "quality": 8,
        "items": [],
        "allowed": false
      },
      {
        "quality": 12,
        "items": [],
        "allowed": false
      }
    ],
    "allowed": false
  },
  {
    "quality": 20,
    "items": [],
    "allowed": false
  },
  {
    "quality": 21,
    "items": [],
    "allowed": false
  },
  {
    "quality": 4,
    "items": [],
    "allowed": true
  },
  {
    "id": 1001,
    "name": "WEB 720p",
    "items": [
      {
        "quality": 5,
        "items": [],
        "allowed": true
      },
      {
        "quality": 14,
        "items": [],
        "allowed": true
      }
    ],
    "allowed": true
  },
  {
    "quality": 6,
    "items": [],
    "allowed": true
  },
  {
    "quality": 9,
    "items": [],
    "allowed": true
  },
  {
    "id": 1002,
    "name": "WEB 1080p",
    "items": [
      {
        "quality": 3,
        "items": [],
        "allowed": true
      },
      {
        "quality": 15,
        "items": [],
        "allowed": true
      }
    ],
    "allowed": true
  },
  {
    "quality": 7,
    "items": [],
    "allowed": true
  },
  {
    "quality": 30,
    "items": [],
    "allowed": true
  },
  {
    "quality": 16,
    "items": [],
    "allowed": false
  },
  {
    "id": 1003,
    "name": "WEB 2160p",
    "items": [
      {
        "quality": 18,
        "items": [],
        "allowed": false
      },
      {
        "quality": 17,
        "items": [],
        "allowed": false
      }
    ],
    "allowed": false
  },
  {
    "quality": 19,
    "items": [],
    "allowed": false
  },
  {
    "quality": 31,
    "items": [],
    "allowed": false
  },
  {
    "quality": 22,
    "items": [],
    "allowed": false
  },
  {
    "quality": 10,
    "items": [],
    "allowed": false
  }
]',1,'[]',0,0,0,1);
CREATE TABLE "ReleaseProfiles" ("Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "Required" TEXT, "Ignored" TEXT, "Tags" TEXT NOT NULL, "Name" TEXT, "Enabled" INTEGER NOT NULL, "IndexerId" INTEGER NOT NULL);
CREATE TABLE "RemotePathMappings" ("Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "Host" TEXT NOT NULL, "RemotePath" TEXT NOT NULL, "LocalPath" TEXT NOT NULL);
CREATE TABLE "RootFolders" ("Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "Path" TEXT NOT NULL);
CREATE TABLE "ScheduledTasks" ("Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "TypeName" TEXT NOT NULL, "Interval" NUMERIC NOT NULL, "LastExecution" DATETIME NOT NULL, "LastStartTime" DATETIME);
INSERT INTO "ScheduledTasks" VALUES(1,'NzbDrone.Core.Messaging.Commands.MessagingCleanupCommand',5,'2024-10-31 00:28:01.9391382Z','0001-01-01 04:57:00Z');
INSERT INTO "ScheduledTasks" VALUES(2,'NzbDrone.Core.Update.Commands.ApplicationCheckUpdateCommand',360,'2024-10-31 00:28:01.9434066Z','0001-01-01 04:57:00Z');
INSERT INTO "ScheduledTasks" VALUES(3,'NzbDrone.Core.HealthCheck.CheckHealthCommand',360,'2024-10-31 00:28:01.9459126Z','0001-01-01 04:57:00Z');
INSERT INTO "ScheduledTasks" VALUES(4,'NzbDrone.Core.Movies.Commands.RefreshMovieCommand',1440,'2024-10-31 00:28:01.9483405Z','0001-01-01 04:57:00Z');
INSERT INTO "ScheduledTasks" VALUES(5,'NzbDrone.Core.Housekeeping.HousekeepingCommand',1440,'2024-10-31 00:28:01.9507492Z','0001-01-01 04:57:00Z');
INSERT INTO "ScheduledTasks" VALUES(6,'NzbDrone.Core.MediaFiles.Commands.CleanUpRecycleBinCommand',1440,'2024-10-31 00:28:01.9531304Z','0001-01-01 04:57:00Z');
INSERT INTO "ScheduledTasks" VALUES(7,'NzbDrone.Core.Movies.Commands.RefreshCollectionsCommand',1440,'2024-10-31 00:28:01.955788Z','0001-01-01 04:57:00Z');
INSERT INTO "ScheduledTasks" VALUES(8,'NzbDrone.Core.Backup.BackupCommand',10080,'2024-10-31 00:28:01.9583336Z','0001-01-01 04:57:00Z');
INSERT INTO "ScheduledTasks" VALUES(9,'NzbDrone.Core.Indexers.RssSyncCommand',30,'2024-10-31 00:28:01.9609145Z','0001-01-01 04:57:00Z');
INSERT INTO "ScheduledTasks" VALUES(10,'NzbDrone.Core.ImportLists.ImportListSyncCommand',5,'2024-10-31 00:28:01.963352Z','0001-01-01 04:57:00Z');
INSERT INTO "ScheduledTasks" VALUES(11,'NzbDrone.Core.Download.RefreshMonitoredDownloadsCommand',1,'2024-10-31 00:28:01.9658885Z','0001-01-01 04:57:00Z');
CREATE TABLE "SubtitleFiles" ("Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "MovieId" INTEGER NOT NULL, "MovieFileId" INTEGER NOT NULL, "RelativePath" TEXT NOT NULL, "Extension" TEXT NOT NULL, "Added" DATETIME NOT NULL, "LastUpdated" DATETIME NOT NULL, "Language" INTEGER NOT NULL, "LanguageTags" TEXT, "Title" TEXT, "Copy" INTEGER NOT NULL DEFAULT 0);
CREATE TABLE "Tags" ("Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "Label" TEXT NOT NULL);
CREATE TABLE "Users" ("Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "Identifier" TEXT NOT NULL, "Username" TEXT NOT NULL, "Password" TEXT NOT NULL, "Salt" TEXT, "Iterations" INTEGER);
CREATE TABLE "VersionInfo" ("Version" INTEGER NOT NULL, "AppliedOn" DATETIME, "Description" TEXT);
INSERT INTO "VersionInfo" VALUES(1,'2024-10-31T00:28:00','InitialSetup');
INSERT INTO "VersionInfo" VALUES(104,'2024-10-31T00:28:00','add_moviefiles_table');
INSERT INTO "VersionInfo" VALUES(105,'2024-10-31T00:28:00','fix_history_movieId');
INSERT INTO "VersionInfo" VALUES(106,'2024-10-31T00:28:00','add_tmdb_stuff');
INSERT INTO "VersionInfo" VALUES(107,'2024-10-31T00:28:00','fix_movie_files');
INSERT INTO "VersionInfo" VALUES(108,'2024-10-31T00:28:00','update_schedule_intervale');
INSERT INTO "VersionInfo" VALUES(109,'2024-10-31T00:28:00','add_movie_formats_to_naming_config');
INSERT INTO "VersionInfo" VALUES(110,'2024-10-31T00:28:00','add_phyiscal_release');
INSERT INTO "VersionInfo" VALUES(111,'2024-10-31T00:28:00','remove_bitmetv');
INSERT INTO "VersionInfo" VALUES(112,'2024-10-31T00:28:00','remove_torrentleech');
INSERT INTO "VersionInfo" VALUES(113,'2024-10-31T00:28:00','remove_broadcasthenet');
INSERT INTO "VersionInfo" VALUES(114,'2024-10-31T00:28:00','remove_fanzub');
INSERT INTO "VersionInfo" VALUES(115,'2024-10-31T00:28:00','update_movie_sorttitle');
INSERT INTO "VersionInfo" VALUES(116,'2024-10-31T00:28:00','update_movie_sorttitle_again');
INSERT INTO "VersionInfo" VALUES(117,'2024-10-31T00:28:00','update_movie_file');
INSERT INTO "VersionInfo" VALUES(118,'2024-10-31T00:28:00','update_movie_slug');
INSERT INTO "VersionInfo" VALUES(119,'2024-10-31T00:28:00','add_youtube_trailer_id');
INSERT INTO "VersionInfo" VALUES(120,'2024-10-31T00:28:00','add_studio');
INSERT INTO "VersionInfo" VALUES(121,'2024-10-31T00:28:00','update_filedate_config');
INSERT INTO "VersionInfo" VALUES(122,'2024-10-31T00:28:00','add_movieid_to_blacklist');
INSERT INTO "VersionInfo" VALUES(123,'2024-10-31T00:28:00','create_netimport_table');
INSERT INTO "VersionInfo" VALUES(124,'2024-10-31T00:28:00','add_preferred_tags_to_profile');
INSERT INTO "VersionInfo" VALUES(125,'2024-10-31T00:28:00','fix_imdb_unique');
INSERT INTO "VersionInfo" VALUES(126,'2024-10-31T00:28:00','update_qualities_and_profiles');
INSERT INTO "VersionInfo" VALUES(127,'2024-10-31T00:28:00','remove_wombles');
INSERT INTO "VersionInfo" VALUES(128,'2024-10-31T00:28:00','remove_kickass');
INSERT INTO "VersionInfo" VALUES(129,'2024-10-31T00:28:00','add_parsed_movie_info_to_pending_release');
INSERT INTO "VersionInfo" VALUES(130,'2024-10-31T00:28:00','remove_wombles_kickass');
INSERT INTO "VersionInfo" VALUES(131,'2024-10-31T00:28:00','make_parsed_episode_info_nullable');
INSERT INTO "VersionInfo" VALUES(132,'2024-10-31T00:28:00','rename_torrent_downloadstation');
INSERT INTO "VersionInfo" VALUES(133,'2024-10-31T00:28:00','add_minimumavailability');
INSERT INTO "VersionInfo" VALUES(134,'2024-10-31T00:28:00','add_remux_qualities_for_the_wankers');
INSERT INTO "VersionInfo" VALUES(135,'2024-10-31T00:28:00','add_haspredbentry_to_movies');
INSERT INTO "VersionInfo" VALUES(136,'2024-10-31T00:28:00','add_pathstate_to_movies');
INSERT INTO "VersionInfo" VALUES(137,'2024-10-31T00:28:00','add_import_exclusions_table');
INSERT INTO "VersionInfo" VALUES(138,'2024-10-31T00:28:00','add_physical_release_note');
INSERT INTO "VersionInfo" VALUES(139,'2024-10-31T00:28:00','consolidate_indexer_baseurl');
INSERT INTO "VersionInfo" VALUES(140,'2024-10-31T00:28:00','add_alternative_titles_table');
INSERT INTO "VersionInfo" VALUES(141,'2024-10-31T00:28:00','fix_duplicate_alt_titles');
INSERT INTO "VersionInfo" VALUES(142,'2024-10-31T00:28:00','movie_extras');
INSERT INTO "VersionInfo" VALUES(143,'2024-10-31T00:28:00','clean_core_tv');
INSERT INTO "VersionInfo" VALUES(144,'2024-10-31T00:28:00','add_cookies_to_indexer_status');
INSERT INTO "VersionInfo" VALUES(145,'2024-10-31T00:28:00','banner_to_fanart');
INSERT INTO "VersionInfo" VALUES(146,'2024-10-31T00:28:00','naming_config_colon_action');
INSERT INTO "VersionInfo" VALUES(147,'2024-10-31T00:28:00','add_custom_formats');
INSERT INTO "VersionInfo" VALUES(148,'2024-10-31T00:28:00','remove_extra_naming_config');
INSERT INTO "VersionInfo" VALUES(149,'2024-10-31T00:28:00','convert_regex_required_tags');
INSERT INTO "VersionInfo" VALUES(150,'2024-10-31T00:28:00','fix_format_tags_double_underscore');
INSERT INTO "VersionInfo" VALUES(151,'2024-10-31T00:28:00','add_tags_to_net_import');
INSERT INTO "VersionInfo" VALUES(152,'2024-10-31T00:28:00','add_custom_filters');
INSERT INTO "VersionInfo" VALUES(153,'2024-10-31T00:28:00','indexer_client_status_search_changes');
INSERT INTO "VersionInfo" VALUES(154,'2024-10-31T00:28:00','add_language_to_files_history_blacklist');
INSERT INTO "VersionInfo" VALUES(155,'2024-10-31T00:28:00','add_update_allowed_quality_profile');
INSERT INTO "VersionInfo" VALUES(156,'2024-10-31T00:28:00','add_download_client_priority');
INSERT INTO "VersionInfo" VALUES(157,'2024-10-31T00:28:00','remove_growl_prowl');
INSERT INTO "VersionInfo" VALUES(158,'2024-10-31T00:28:00','remove_plex_hometheatre');
INSERT INTO "VersionInfo" VALUES(159,'2024-10-31T00:28:00','add_webrip_qualites');
INSERT INTO "VersionInfo" VALUES(160,'2024-10-31T00:28:00','health_issue_notification');
INSERT INTO "VersionInfo" VALUES(161,'2024-10-31T00:28:00','speed_improvements');
INSERT INTO "VersionInfo" VALUES(162,'2024-10-31T00:28:00','fix_profile_format_default');
INSERT INTO "VersionInfo" VALUES(163,'2024-10-31T00:28:00','task_duration');
INSERT INTO "VersionInfo" VALUES(164,'2024-10-31T00:28:00','movie_collections_crew');
INSERT INTO "VersionInfo" VALUES(165,'2024-10-31T00:28:00','remove_custom_formats_from_quality_model');
INSERT INTO "VersionInfo" VALUES(166,'2024-10-31T00:28:00','fix_tmdb_list_config');
INSERT INTO "VersionInfo" VALUES(167,'2024-10-31T00:28:00','remove_movie_pathstate');
INSERT INTO "VersionInfo" VALUES(168,'2024-10-31T00:28:00','custom_format_rework');
INSERT INTO "VersionInfo" VALUES(169,'2024-10-31T00:28:00','custom_format_scores');
INSERT INTO "VersionInfo" VALUES(170,'2024-10-31T00:28:00','fix_trakt_list_config');
INSERT INTO "VersionInfo" VALUES(171,'2024-10-31T00:28:00','quality_definition_preferred_size');
INSERT INTO "VersionInfo" VALUES(172,'2024-10-31T00:28:00','add_download_history');
INSERT INTO "VersionInfo" VALUES(173,'2024-10-31T00:28:00','net_import_status');
INSERT INTO "VersionInfo" VALUES(174,'2024-10-31T00:28:00','email_multiple_addresses');
INSERT INTO "VersionInfo" VALUES(175,'2024-10-31T00:28:00','remove_chown_and_folderchmod_config');
INSERT INTO "VersionInfo" VALUES(176,'2024-10-31T00:28:00','movie_recommendations');
INSERT INTO "VersionInfo" VALUES(177,'2024-10-31T00:28:00','language_improvements');
INSERT INTO "VersionInfo" VALUES(178,'2024-10-31T00:28:00','new_list_server');
INSERT INTO "VersionInfo" VALUES(179,'2024-10-31T00:28:00','movie_translation_indexes');
INSERT INTO "VersionInfo" VALUES(180,'2024-10-31T00:28:00','fix_invalid_profile_references');
INSERT INTO "VersionInfo" VALUES(181,'2024-10-31T00:28:00','list_movies_table');
INSERT INTO "VersionInfo" VALUES(182,'2024-10-31T00:28:00','on_delete_notification');
INSERT INTO "VersionInfo" VALUES(183,'2024-10-31T00:28:00','download_propers_config');
INSERT INTO "VersionInfo" VALUES(184,'2024-10-31T00:28:00','add_priority_to_indexers');
INSERT INTO "VersionInfo" VALUES(185,'2024-10-31T00:28:00','add_alternative_title_indices');
INSERT INTO "VersionInfo" VALUES(186,'2024-10-31T00:28:00','fix_tmdb_duplicates');
INSERT INTO "VersionInfo" VALUES(187,'2024-10-31T00:28:00','swap_filechmod_for_folderchmod');
INSERT INTO "VersionInfo" VALUES(188,'2024-10-31T00:28:00','mediainfo_channels');
INSERT INTO "VersionInfo" VALUES(189,'2024-10-31T00:28:00','add_update_history');
INSERT INTO "VersionInfo" VALUES(190,'2024-10-31T00:28:00','update_awesome_hd_link');
INSERT INTO "VersionInfo" VALUES(191,'2024-10-31T00:28:00','remove_awesomehd');
INSERT INTO "VersionInfo" VALUES(192,'2024-10-31T00:28:00','add_on_delete_to_notifications');
INSERT INTO "VersionInfo" VALUES(194,'2024-10-31T00:28:00','add_bypass_to_delay_profile');
INSERT INTO "VersionInfo" VALUES(195,'2024-10-31T00:28:00','update_notifiarr');
INSERT INTO "VersionInfo" VALUES(196,'2024-10-31T00:28:00','legacy_mediainfo_hdr');
INSERT INTO "VersionInfo" VALUES(197,'2024-10-31T00:28:00','rename_blacklist_to_blocklist');
INSERT INTO "VersionInfo" VALUES(198,'2024-10-31T00:28:00','add_indexer_tags');
INSERT INTO "VersionInfo" VALUES(199,'2024-10-31T00:28:00','mediainfo_to_ffmpeg');
INSERT INTO "VersionInfo" VALUES(200,'2024-10-31T00:28:00','cdh_per_downloadclient');
INSERT INTO "VersionInfo" VALUES(201,'2024-10-31T00:28:00','migrate_discord_from_slack');
INSERT INTO "VersionInfo" VALUES(202,'2024-10-31T00:28:00','remove_predb');
INSERT INTO "VersionInfo" VALUES(203,'2024-10-31T00:28:00','add_on_update_to_notifications');
INSERT INTO "VersionInfo" VALUES(204,'2024-10-31T00:28:00','ensure_identity_on_id_columns');
INSERT INTO "VersionInfo" VALUES(205,'2024-10-31T00:28:00','download_client_per_indexer');
INSERT INTO "VersionInfo" VALUES(206,'2024-10-31T00:28:00','multiple_ratings_support');
INSERT INTO "VersionInfo" VALUES(207,'2024-10-31T00:28:00','movie_metadata');
INSERT INTO "VersionInfo" VALUES(208,'2024-10-31T00:28:00','collections');
INSERT INTO "VersionInfo" VALUES(209,'2024-10-31T00:28:00','movie_meta_collection_index');
INSERT INTO "VersionInfo" VALUES(210,'2024-10-31T00:28:00','movie_added_notifications');
INSERT INTO "VersionInfo" VALUES(211,'2024-10-31T00:28:00','more_movie_meta_index');
INSERT INTO "VersionInfo" VALUES(212,'2024-10-31T00:28:01','postgres_update_timestamp_columns_to_with_timezone');
INSERT INTO "VersionInfo" VALUES(214,'2024-10-31T00:28:01','add_language_tags_to_subtitle_files');
INSERT INTO "VersionInfo" VALUES(215,'2024-10-31T00:28:01','add_salt_to_users');
INSERT INTO "VersionInfo" VALUES(216,'2024-10-31T00:28:01','clean_alt_titles');
INSERT INTO "VersionInfo" VALUES(217,'2024-10-31T00:28:01','remove_omg');
INSERT INTO "VersionInfo" VALUES(218,'2024-10-31T00:28:01','add_additional_info_to_pending_releases');
INSERT INTO "VersionInfo" VALUES(219,'2024-10-31T00:28:01','add_result_to_commands');
INSERT INTO "VersionInfo" VALUES(220,'2024-10-31T00:28:01','health_restored_notification');
INSERT INTO "VersionInfo" VALUES(221,'2024-10-31T00:28:01','add_on_manual_interaction_required_to_notifications');
INSERT INTO "VersionInfo" VALUES(222,'2024-10-31T00:28:01','remove_rarbg');
INSERT INTO "VersionInfo" VALUES(223,'2024-10-31T00:28:01','remove_invalid_roksbox_metadata_images');
INSERT INTO "VersionInfo" VALUES(224,'2024-10-31T00:28:01','list_sync_time');
INSERT INTO "VersionInfo" VALUES(225,'2024-10-31T00:28:01','add_tags_to_collections');
INSERT INTO "VersionInfo" VALUES(226,'2024-10-31T00:28:01','add_download_client_tags');
INSERT INTO "VersionInfo" VALUES(227,'2024-10-31T00:28:01','add_auto_tagging');
INSERT INTO "VersionInfo" VALUES(228,'2024-10-31T00:28:01','add_custom_format_score_bypass_to_delay_profile');
INSERT INTO "VersionInfo" VALUES(229,'2024-10-31T00:28:01','update_restrictions_to_release_profiles');
INSERT INTO "VersionInfo" VALUES(230,'2024-10-31T00:28:01','rename_quality_profiles');
INSERT INTO "VersionInfo" VALUES(231,'2024-10-31T00:28:01','update_images_remote_url');
INSERT INTO "VersionInfo" VALUES(232,'2024-10-31T00:28:01','add_notification_status');
INSERT INTO "VersionInfo" VALUES(233,'2024-10-31T00:28:01','rename_deprecated_indexer_flags');
INSERT INTO "VersionInfo" VALUES(234,'2024-10-31T00:28:01','movie_last_searched_time');
INSERT INTO "VersionInfo" VALUES(235,'2024-10-31T00:28:01','email_encryption');
INSERT INTO "VersionInfo" VALUES(236,'2024-10-31T00:28:01','clear_last_rss_releases_info');
INSERT INTO "VersionInfo" VALUES(237,'2024-10-31T00:28:01','add_indexes');
INSERT INTO "VersionInfo" VALUES(238,'2024-10-31T00:28:01','parse_title_from_existing_subtitle_files');
INSERT INTO "VersionInfo" VALUES(239,'2024-10-31T00:28:01','add_minimum_upgrade_format_score_to_quality_profiles');
CREATE UNIQUE INDEX "IX_Config_Key" ON "Config" ("Key" ASC);
CREATE UNIQUE INDEX "IX_RootFolders_Path" ON "RootFolders" ("Path" ASC);
CREATE UNIQUE INDEX "IX_QualityDefinitions_Quality" ON "QualityDefinitions" ("Quality" ASC);
CREATE UNIQUE INDEX "IX_QualityDefinitions_Title" ON "QualityDefinitions" ("Title" ASC);
CREATE UNIQUE INDEX "IX_Tags_Label" ON "Tags" ("Label" ASC);
CREATE UNIQUE INDEX "IX_Users_Identifier" ON "Users" ("Identifier" ASC);
CREATE UNIQUE INDEX "IX_Users_Username" ON "Users" ("Username" ASC);
CREATE UNIQUE INDEX "IX_ImportExclusions_TmdbId" ON "ImportExclusions" ("TmdbId" ASC);
CREATE UNIQUE INDEX "IX_Indexers_Name" ON "Indexers" ("Name" ASC);
CREATE UNIQUE INDEX "IX_Profiles_Name" ON "QualityProfiles" ("Name" ASC);
CREATE UNIQUE INDEX "IX_CustomFormats_Name" ON "CustomFormats" ("Name" ASC);
CREATE UNIQUE INDEX "IX_Credits_CreditTmdbId" ON "Credits" ("CreditTmdbId" ASC);
CREATE INDEX "IX_MovieTranslations_Language" ON "MovieTranslations" ("Language" ASC);
CREATE INDEX "IX_MovieTranslations_CleanTitle" ON "MovieTranslations" ("CleanTitle" ASC);
CREATE INDEX "IX_ImportListMovies_MovieMetadataId" ON "ImportListMovies" ("MovieMetadataId" ASC);
CREATE INDEX "IX_MovieTranslations_MovieMetadataId" ON "MovieTranslations" ("MovieMetadataId" ASC);
CREATE INDEX "IX_Credits_MovieMetadataId" ON "Credits" ("MovieMetadataId" ASC);
CREATE UNIQUE INDEX "IX_Collections_TmdbId" ON "Collections" ("TmdbId" ASC);
CREATE UNIQUE INDEX "IX_DownloadClientStatus_ProviderId" ON "DownloadClientStatus" ("ProviderId" ASC);
CREATE INDEX "IX_DownloadHistory_EventType" ON "DownloadHistory" ("EventType" ASC);
CREATE INDEX "IX_DownloadHistory_MovieId" ON "DownloadHistory" ("MovieId" ASC);
CREATE INDEX "IX_DownloadHistory_DownloadId" ON "DownloadHistory" ("DownloadId" ASC);
CREATE INDEX "IX_History_Date" ON "History" ("Date" ASC);
CREATE UNIQUE INDEX "IX_IndexerStatus_ProviderId" ON "IndexerStatus" ("ProviderId" ASC);
CREATE INDEX "IX_MovieFiles_MovieId" ON "MovieFiles" ("MovieId" ASC);
CREATE UNIQUE INDEX "IX_MovieMetadata_TmdbId" ON "MovieMetadata" ("TmdbId" ASC);
CREATE INDEX "IX_MovieMetadata_CleanTitle" ON "MovieMetadata" ("CleanTitle" ASC);
CREATE INDEX "IX_MovieMetadata_CleanOriginalTitle" ON "MovieMetadata" ("CleanOriginalTitle" ASC);
CREATE INDEX "IX_MovieMetadata_CollectionTmdbId" ON "MovieMetadata" ("CollectionTmdbId" ASC);
CREATE UNIQUE INDEX "IX_ScheduledTasks_TypeName" ON "ScheduledTasks" ("TypeName" ASC);
CREATE UNIQUE INDEX "UC_Version" ON "VersionInfo" ("Version" ASC);
CREATE INDEX "IX_AlternativeTitles_CleanTitle" ON "AlternativeTitles" ("CleanTitle" ASC);
CREATE INDEX "IX_AlternativeTitles_MovieMetadataId" ON "AlternativeTitles" ("MovieMetadataId" ASC);
CREATE UNIQUE INDEX "IX_NetImportStatus_ProviderId" ON "ImportListStatus" ("ProviderId" ASC);
CREATE UNIQUE INDEX "IX_AutoTagging_Name" ON "AutoTagging" ("Name" ASC);
CREATE UNIQUE INDEX "IX_Movies_MovieMetadataId" ON "Movies" ("MovieMetadataId" ASC);
CREATE UNIQUE INDEX "IX_NetImport_Name" ON "ImportLists" ("Name" ASC);
CREATE UNIQUE INDEX "IX_NotificationStatus_ProviderId" ON "NotificationStatus" ("ProviderId" ASC);
CREATE INDEX "IX_Blocklist_MovieId" ON "Blocklist" ("MovieId" ASC);
CREATE INDEX "IX_Blocklist_Date" ON "Blocklist" ("Date" ASC);
CREATE INDEX "IX_History_MovieId_Date" ON "History" ("MovieId" ASC, "Date" DESC);
CREATE INDEX "IX_History_DownloadId_Date" ON "History" ("DownloadId" ASC, "Date" DESC);
CREATE INDEX "IX_Movies_MovieFileId" ON "Movies" ("MovieFileId" ASC);
CREATE INDEX "IX_Movies_Path" ON "Movies" ("Path" ASC);
DELETE FROM "sqlite_sequence";
INSERT INTO "sqlite_sequence" VALUES('DelayProfiles',1);
INSERT INTO "sqlite_sequence" VALUES('Indexers',0);
INSERT INTO "sqlite_sequence" VALUES('Notifications',0);
INSERT INTO "sqlite_sequence" VALUES('QualityProfiles',6);
INSERT INTO "sqlite_sequence" VALUES('NamingConfig',1);
INSERT INTO "sqlite_sequence" VALUES('CustomFormats',0);
INSERT INTO "sqlite_sequence" VALUES('Credits',0);
INSERT INTO "sqlite_sequence" VALUES('MovieTranslations',0);
INSERT INTO "sqlite_sequence" VALUES('ImportListMovies',0);
INSERT INTO "sqlite_sequence" VALUES('Blocklist',0);
INSERT INTO "sqlite_sequence" VALUES('Collections',0);
INSERT INTO "sqlite_sequence" VALUES('Commands',0);
INSERT INTO "sqlite_sequence" VALUES('DownloadClientStatus',0);
INSERT INTO "sqlite_sequence" VALUES('DownloadHistory',0);
INSERT INTO "sqlite_sequence" VALUES('ExtraFiles',0);
INSERT INTO "sqlite_sequence" VALUES('History',0);
INSERT INTO "sqlite_sequence" VALUES('IndexerStatus',0);
INSERT INTO "sqlite_sequence" VALUES('MetadataFiles',0);
INSERT INTO "sqlite_sequence" VALUES('MovieFiles',0);
INSERT INTO "sqlite_sequence" VALUES('MovieMetadata',0);
INSERT INTO "sqlite_sequence" VALUES('PendingReleases',0);
INSERT INTO "sqlite_sequence" VALUES('ScheduledTasks',11);
INSERT INTO "sqlite_sequence" VALUES('SubtitleFiles',0);
INSERT INTO "sqlite_sequence" VALUES('AlternativeTitles',0);
INSERT INTO "sqlite_sequence" VALUES('ImportListStatus',0);
INSERT INTO "sqlite_sequence" VALUES('ReleaseProfiles',0);
INSERT INTO "sqlite_sequence" VALUES('Movies',0);
INSERT INTO "sqlite_sequence" VALUES('ImportLists',0);
INSERT INTO "sqlite_sequence" VALUES('QualityDefinitions',30);
INSERT INTO "sqlite_sequence" VALUES('Metadata',4);
COMMIT;
