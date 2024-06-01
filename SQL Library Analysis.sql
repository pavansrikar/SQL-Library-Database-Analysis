Create database if not exists librarydb;
use librarydb;

CREATE TABLE tbl_publisher(publisher_PublisherName varchar(50) primary key not null,
						   publisher_PublisherAddress varchar(100) not null,
						   publisher_PublisherPhone varchar(50) not null);

CREATE TABLE tbl_book(book_BookID int primary key not null auto_increment,
					  book_Title varchar(50) not null,
					  book_PublisherName varchar(50) not null,
                      FOREIGN KEY (book_PublisherName)  REFERENCES tbl_publisher (publisher_PublisherName) ON UPDATE CASCADE ON DELETE CASCADE);
                      
CREATE TABLE tbl_book_authors(book_authors_AuthorID int primary key not null auto_increment,
							  book_authors_BookID int not null,
                              book_authors_AuthorName varchar(50) not null,
                              FOREIGN KEY (book_authors_BookID)  REFERENCES tbl_book (book_BookID) ON UPDATE CASCADE ON DELETE CASCADE);
                              
CREATE TABLE tbl_library_branch(library_branch_BranchID int primary key not null auto_increment,
						        library_branch_BranchName varchar(50) not null,
								library_branch_BranchAddress varchar(50) not null);
                              
CREATE TABLE tbl_book_copies(book_copies_CopiesID int primary key not null auto_increment,
							  book_copies_BookID int not null,
                              book_copies_BranchID int not null,
                              book_copies_No_Of_Copies int not null,
                              FOREIGN KEY (book_copies_BookID)  REFERENCES tbl_book (book_BookID) ON UPDATE CASCADE ON DELETE CASCADE,
                              FOREIGN KEY (book_copies_BranchID)  REFERENCES tbl_library_branch (library_branch_BranchID) ON UPDATE CASCADE ON DELETE CASCADE);
                              
                           
CREATE TABLE tbl_borrower(borrower_CardNo int primary key not null auto_increment,
						  borrower_BorrowerName varchar(50) not null,
						  borrower_BorrowerAddress varchar(50) not null,
						  borrower_BorrowerPhone varchar(50) not null);
                                                          
CREATE TABLE tbl_book_loans(book_loans_LoansID int primary key not null auto_increment,
							book_loans_BookID int not null,
							book_loans_BranchID int not null,
							book_loans_CardNo int not null,
							book_loans_DateOut varchar(255) not null,
							book_loans_DueDate varchar(255) not null,
                            FOREIGN KEY (book_loans_BookID)  REFERENCES tbl_book (book_BookID) ON UPDATE CASCADE ON DELETE CASCADE,
                            FOREIGN KEY (book_loans_BranchID)  REFERENCES tbl_library_branch (library_branch_BranchID) ON UPDATE CASCADE ON DELETE CASCADE,
                            FOREIGN KEY (book_loans_CardNo)  REFERENCES tbl_borrower (borrower_CardNo) ON UPDATE CASCADE ON DELETE CASCADE);
                            
select * from tbl_publisher;
select * from tbl_borrower;
select * from tbl_library_branch;
select * from tbl_book;
select * from tbl_book_loans;
select * from tbl_book_authors;
select * from tbl_book_copies;
                            

--- How many copies of the book titled "The Lost Tribe" are owned by the library branch whose name is "Sharpstown"?
SELECT count(book_copies_No_Of_Copies)
FROM tbl_book, tbl_book_copies, tbl_library_branch
WHERE book_Title='The Lost Tribe' AND library_branch_BranchName='Sharpstown' ;

--- How many copies of the book titled "The Lost Tribe" are owned by each library branch?
SELECT library_branch_BranchName, SUM(book_copies_No_Of_Copies) AS copies_of_lost_tribe
FROM 
	tbl_library_branch 
JOIN 
	tbl_book_copies ON tbl_library_branch.library_branch_BranchID = tbl_book_copies.book_copies_BranchID
JOIN 
	tbl_book ON tbl_book.book_BookID = tbl_book_copies.book_copies_BookID
WHERE 
	tbl_book.book_Title = 'The Lost Tribe'
GROUP BY library_branch_BranchName;

--- Retrieve the names of all borrowers who do not have any books checked out.
SELECT borrower_BorrowerName 
FROM tbl_Borrower b
LEFT JOIN tbl_book_loans bl ON bl.book_loans_CardNo = b.borrower_CardNo
WHERE bl.book_loans_CardNo IS NULL;

--- For each book that is loaned out from the "Sharpstown" branch and whose DueDate is 2/3/18, retrieve the book title, the borrower's name, and the borrower's address.
SELECT
    book_Title, borrower_BorrowerName, borrower_BorrowerAddress
FROM
    tbl_book b
JOIN
    tbl_book_loans bl ON book_loans_BookID = b.book_BookID
JOIN
    tbl_Borrower br ON book_loans_CardNo = br.borrower_CardNo
JOIN
    tbl_library_branch lb ON book_loans_BranchID = lb.library_branch_BranchID
WHERE
    lb.library_branch_BranchName = 'Sharpstown'
    AND book_loans_DueDate = '2/3/18';

--- For each library branch, retrieve the branch name and the total number of books loaned out from that branch.    
SELECT
	library_branch_BranchName, sum(book_loans_BookID) AS Total_Books_Loaned
FROM
	tbl_library_branch lb 
JOIN
    tbl_book_loans bl ON lb.library_branch_branchID = bl.book_loans_BranchID
GROUP BY
    lb.library_branch_branchID, lb.library_branch_BranchName;
    
--- Retrieve the names, addresses, and number of books checked out for all borrowers who have more than five books checked out.
SELECT
    borrower_BorrowerName,borrower_BorrowerAddress , 
    COUNT(bl.book_loans_BookID) AS NumberOfBooksCheckedOut
FROM
    tbl_borrower b
JOIN
   tbl_book_loans bl ON b.borrower_CardNo = bl.book_loans_CardNo
where
    bl.book_loans_BookID  > 5
GROUP BY
    borrower_BorrowerName,borrower_BorrowerAddress;
    
--- For each book authored by "Stephen King", retrieve the title and the number of copies owned by the library branch whose name is "Central".
SELECT
    book_Title,
    book_copies_No_Of_Copies AS NumberOfCopies
FROM
	tbl_book_authors ba
JOIN
    tbl_book b ON ba.book_authors_BookID = b.book_BookID
JOIN
    tbl_book_copies bc ON b.book_BookID= bc.book_copies_BookID
JOIN
    tbl_library_branch lb ON bc.book_copies_BranchID = lb.library_branch_branchID
WHERE
    ba.book_authors_AuthorName = 'Stephen King'
    AND lb.library_branch_BranchName = 'Central';
    
