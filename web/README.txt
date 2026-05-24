Entire SQL section right here

create table Users
(
    UserID char(16) for bit data not null primary key,
    UserGivenName varchar(32),
    UserLastName varchar(32) not null,
    UserEmail varchar(64),
    UserPassword char(64) not null,
    UserType int not null
);

create table Courses
(
    CourseID char(16) for bit data not null primary key,
    CourseName varchar(64) not null,
    CourseDescription varchar(256)
);

create table Activities
(
    ActivityID char(16) for bit data not null primary key,
    ActivityName varchar(64) not null,
    ActivityDescription varchar(256),
    ActivityScore int,
    ActivityParent char(16) for bit data, foreign key (ActivityParent) references Courses(CourseID) on delete cascade,
    ActivityStatus boolean not null,
    ActivityStart timestamp,
    ActivityEnd timestamp
);

create table Prerequisites
(
    PrerequisiteID char(16) for bit data not null primary key,
    PrerequisiteSubject char(16) for bit data not null, foreign key (PrerequisiteSubject) references Activities(ActivityID),
    PrerequisiteObject char(16) for bit data not null, foreign key (PrerequisiteObject) references Activities(ActivityID)
);

create table Job
(
    JobID char(16) for bit data primary key,
    JobSubject char(16) for bit data not null, foreign key (JobSubject) references Activities(ActivityID) on delete cascade, 
    JobWorker char(16) for bit data not null, foreign key (JobWorker) references Users(UserID) on delete cascade,
    JobStatus int not null default 0,
    JobScore int,
    JobStart timestamp not null default current_timestamp,
    JobEnd timestamp
);

create table Registration
(
    RegistrationID char(16) for bit data primary key,
    RegistrationSubject char(16) for bit data not null, foreign key (RegistrationSubject) references Courses(CourseID) on delete cascade, 
    RegistrationWorker char(16) for bit data not null, foreign key (RegistrationWorker) references Users(UserID) on delete cascade
);

select * from Users;

SELECT ACTIVITYID, ACTIVITYNAME, COURSENAME FROM ACTIVITIES
INNER JOIN COURSES ON ACTIVITIES.ACTIVITYPARENT=COURSES.COURSEID
ORDER BY ACTIVITYID ASC


SELECT * FROM REGISTRATION

SELECT * FROM JOB

ALTER TABLE JOB ALTER COLUMN JOBSTATUS SET DATA TYPE INT

ALTER TABLE JOB DROP COLUMN JOBSTATUS;
ALTER TABLE JOB ADD JOBSTATUS INT NOT NULL DEFAULT 0

TRUNCATE TABLE REGISTRATION

ALTER TABLE ACTIVITIES DROP FOREIGN KEY SQL260522082115501;
ALTER TABLE ACTIVITIES ADD FOREIGN KEY (ACTIVITYPARENT) references Courses(CourseID) ON DELETE CASCADE;


alter table Registration drop foreign key SQL260523212943161;
alter table Registration drop foreign key SQL260523212943162;
alter table Registration ADD foreign key (RegistrationSubject) references Courses(CourseID) on delete cascade;
alter table Registration ADD foreign key (RegistrationWorker) references Users(UserID) on delete cascade;
alter table Job drop foreign key SQL260522082115561;
alter table Job drop foreign key SQL260522082115562;
alter table Job ADD foreign key (JobSubject) references Activities(ActivityID) on delete cascade;
alter table Job ADD foreign key (JobWorker) references Users(UserID) on delete cascade;

SELECT * FROM USERS INNER JOIN REGISTRATION ON USERS.USERID = REGISTRATION.REGISTRATIONWORKER INNER JOIN ACTIVITIES ON ACTIVITIES.ACTIVITYPARENT = REGISTRATION.REGISTRATIONSUBJECT LEFT JOIN JOB ON USERS.USERID = JOB.JOBWORKER WHERE USERTYPE = 0 ORDER BY USERLASTNAME ASC


SELECT * FROM USERS LEFT JOIN JOB ON JOB.JOBWORKER = USERS.USERID ORDER BY USERLASTNAME ASC
