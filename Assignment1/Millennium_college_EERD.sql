-- SQL Server Management Studio 20 --

--CREATE DATABASE Millennium_College
USE Millennium_College

DROP TABLE IF EXISTS Enrollment
DROP TABLE IF EXISTS Class
DROP TABLE IF EXISTS Student
DROP TABLE IF EXISTS Course
DROP TABLE IF EXISTS Instructor

CREATE TABLE Student (
	Student_ID		INT	 PRIMARY KEY,
	Student_name	VARCHAR(100) NOT NULL,
	Major			VARCHAR(2)   NOT NULL
);

CREATE TABLE Course (
	Course_ID		INT   PRIMARY KEY,
	Course_Name		VARCHAR(50)  UNIQUE NOT NULL
);

CREATE TABLE Instructor (
	Instructor_ID   INT   PRIMARY KEY,
	Instructor_name VARCHAR(100) NOT NULL,
	Location		VARCHAR(3)   UNIQUE NOT NULL,
);

CREATE TABLE Class (
	Class_ID		INT	  PRIMARY KEY,
	Course_ID		INT FOREIGN KEY REFERENCES Course(Course_ID),
	Instructor_ID	INT FOREIGN KEY REFERENCES Instructor(Instructor_ID),
	Semester		VARCHAR(3) NOT NULL,
	Academic_Year	INT NOT NULL
);

CREATE TABLE Enrollment (
	Enrollment_ID   INT     PRIMARY KEY,
	Student_ID		INT FOREIGN KEY REFERENCES Student(Student_ID),
	Class_ID		INT FOREIGN KEY REFERENCES Class(Class_ID),
	Semester		VARCHAR(3) NOT NULL,
	Academic_Year   INT		NOT NULL,
	CGrade			CHAR(1) NOT NULL,
	IGrade			NUMERIC(4, 2) NOT NULL
);
