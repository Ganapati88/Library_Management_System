create database library_db;
use library_db;

-- Table: tbl_publisher
CREATE TABLE tbl_publisher (
    publisher_PublisherName VARCHAR(255) PRIMARY KEY,
    publisher_PublisherAddress TEXT,
    publisher_PublisherPhone VARCHAR(15)
);

-- Table: tbl_book
CREATE TABLE tbl_book (
    book_BookID INT PRIMARY KEY,
    book_Title VARCHAR(255),
    book_PublisherName VARCHAR(255),
    FOREIGN KEY (book_PublisherName) REFERENCES tbl_publisher(publisher_PublisherName)
);

-- Table: tbl_book_authors
drop table tbl_book_authors;
CREATE TABLE tbl_book_authors (
    book_authors_AuthorID INT PRIMARY KEY auto_increment,
    book_authors_BookID INT,
    book_authors_AuthorName VARCHAR(255),
    FOREIGN KEY (book_authors_BookID) REFERENCES tbl_book(book_BookID)
);

-- Table: tbl_library_branch
CREATE TABLE tbl_library_branch (
    library_branch_BranchID INT PRIMARY KEY auto_increment,
    library_branch_BranchName VARCHAR(255),
    library_branch_BranchAddress TEXT
);

-- Table: tbl_book_copies
drop table tbl_book_copies;
CREATE TABLE tbl_book_copies (
    book_copies_CopiesID INT PRIMARY KEY auto_increment,
    book_copies_BookID INT,
    book_copies_BranchID INT,
    book_copies_No_Of_Copies INT,
    FOREIGN KEY (book_copies_BookID) REFERENCES tbl_book(book_BookID),
    FOREIGN KEY (book_copies_BranchID) REFERENCES tbl_library_branch(library_branch_BranchID)
);

-- Table: tbl_borrower
CREATE TABLE tbl_borrower (
    borrower_CardNo INT PRIMARY KEY,
    borrower_BorrowerName VARCHAR(255),
    borrower_BorrowerAddress TEXT,
    borrower_BorrowerPhone VARCHAR(15)
);

-- Table: tbl_book_loans
drop table tbl_book_loans;
CREATE TABLE tbl_book_loans (
    book_loans_LoansID INT PRIMARY KEY auto_increment,
    book_loans_BookID INT,
    book_loans_BranchID INT,
    book_loans_CardNo INT,
    book_loans_DateOut varchar(50),
    book_loans_DueDate varchar(50),
    FOREIGN KEY (book_loans_BookID) REFERENCES tbl_book(book_BookID),
    FOREIGN KEY (book_loans_BranchID) REFERENCES tbl_library_branch(library_branch_BranchID),
    FOREIGN KEY (book_loans_CardNo) REFERENCES tbl_borrower(borrower_CardNo)
);

UPDATE tbl_book_loans
SET
book_loans_dateout = STR_TO_DATE(book_loans_dateout,'%m/%d/%y'),
book_loans_duedate = STR_TO_DATE(book_loans_duedate,'%m/%d/%y');


SELECT * FROM tbl_publisher;
SELECT * FROM tbl_book;
SELECT * FROM tbl_book_authors;
SELECT * FROM tbl_library_branch;
SELECT * FROM tbl_book_copies;
SELECT * FROM tbl_borrower;
SELECT * FROM tbl_book_loans;

-#Module 1 – Book Analytics

  #1. How many copies of the book titled "The Lost Tribe" are owned by the library branch whose name is "Sharpstown"?

select sum(tbc.book_copies_no_of_copies),tb.book_title,tl.library_branch_branchname
from tbl_book as tb
join tbl_book_copies as tbc
on tb.book_bookid=tbc.book_copies_bookid
join tbl_library_branch as tl
on tbc.book_copies_branchid=tl.library_branch_branchid
where tb.book_title='the lost tribe'and tl.library_branch_branchname='sharpstown'
group by tb.book_title,tl.library_branch_branchname;


   #2. How many copies of the book titled "The Lost Tribe" are owned by each librarybranch?

select sum(tbc.book_copies_no_of_copies),tb.book_title,tl.library_branch_branchname
from tbl_book as tb
join tbl_book_copies as tbc
on tb.book_bookid=tbc.book_copies_bookid
join tbl_library_branch as tl
on tbc.book_copies_branchid=tl.library_branch_branchid
where tb.book_title='the lost tribe'
group by tb.book_title,tl.library_branch_branchname;

    #3. For each book authored by "Stephen King", retrieve the title and the number of copies owned by the library branch whose name is "Central"

select tb.book_title,tbc.book_copies_no_of_copies from tbl_book as tb
join tbl_book_authors as tba
on tb.book_bookid=tba.book_authors_bookid
join tbl_book_copies as tbc
on tb.book_bookid=tbc.book_copies_bookid
join tbl_library_branch as tlb
on tbc.book_copies_branchid=tlb.library_branch_branchid
where tba.book_authors_authorname='stephen king' and tlb.library_branch_branchname='central'
;
    #4.Which books are borrowed the most across all library branches?

select tb.book_title,count(tbl.book_loans_loansid) as most_borrowed_books from tbl_book_loans as tbl
join tbl_book as tb
on tbl.book_loans_bookid=tb.book_bookid
group by tb.book_title
order by most_borrowed_books desc;


     #5.Which books have the lowest borrowing frequency?
	
select tb.book_title,count(tbl.book_loans_loansid) as times_borrowed from tbl_book AS tb
left join tbl_book_loans as tbl
on tb.book_bookid = tbl.book_loans_bookid
group by tb.book_title
order by times_borrowed asc;



#Module 2 – Borrower Analytics

   #1. Retrieve the names of all borrowers who do not have any books checked out.

select * from tbl_borrower as tbo
left join tbl_book_loans as tbl
on tbo.borrower_cardno=tbl.book_loans_cardno
where book_loans_CardNo is null;

    #2. Retrieve the names, addresses, and number of books checked out for all borrowers who have more than five books checked out

select tbo.borrower_borrowername,tbo.borrower_borroweraddress,count(tbl.book_loans_CardNo) as total_no_of_books from tbl_borrower as tbo
left join tbl_book_loans as tbl
on tbo.borrower_cardno=tbl.book_loans_cardno
group by tbo.borrower_borrowername,tbo.borrower_borroweraddress
having total_no_of_books>5;
  
	#3.Who are the Top 5 most active borrowers?
    
select tbo.borrower_borrowername,tbo.borrower_borroweraddress,count(tbl.book_loans_loansid) as total_books_borrowed 
from tbl_borrower as tbo
join tbl_book_loans as tbl
on tbo.borrower_cardno = tbl.book_loans_cardno
group by tbo.borrower_cardno,tbo.borrower_borrowername,tbo.borrower_borroweraddress
order by total_books_borrowed desc
limit 5;

   #4.What is the Average Number of Books Borrowed per Borrower?
   
select AVG(total_books_borrowed) as average_books_borrowed
FROM
(
    SELECT
        tbo.borrower_cardno,
        COUNT(tbl.book_loans_loansid) AS total_books_borrowed
    FROM tbl_borrower AS tbo
    INNER JOIN tbl_book_loans AS tbl
        ON tbo.borrower_cardno = tbl.book_loans_cardno
    GROUP BY tbo.borrower_cardno
) AS borrower_summary;

    #5.Which borrowers currently have the highest number of books checked out?
   
select tbo.borrower_borrowername,tbo.borrower_borroweraddress,count(tbl.book_loans_loansid) as books_checked_out
from tbl_borrower as tbo
join tbl_book_loans as tbl
on tbo.borrower_cardno = tbl.book_loans_cardno
group by tbo.borrower_cardno,tbo.borrower_borrowername,tbo.borrower_borroweraddress
order by books_checked_out desc;

#Module 3 – Branch Analytics

   #1. For each library branch, retrieve the branch name and the total number of booksloaned out from that branch

select tlb.library_branch_branchname,(count(tbl.book_loans_loansid)) as total_books_loaned from tbl_library_branch as tlb
left join tbl_book_loans as tbl
on tlb.library_branch_branchid=tbl.book_loans_branchid
group by tlb.library_branch_branchname;

   #2.Which library branch owns the highest number of book copies?
   
select tlb.library_branch_branchname,sum(tbc.book_copies_no_of_copies) as total_book_copies from tbl_library_branch as tlb
join tbl_book_copies as tbc
on tlb.library_branch_branchid = tbc.book_copies_branchid
group by tlb.library_branch_branchid,tlb.library_branch_branchname
order by total_book_copies desc;

   #3.Which library branch has processed the highest number of loan transactions?
   
select tlb.library_branch_branchname,count(tbl.book_loans_loansid) as total_loan_transactions from tbl_library_branch as tlb
join tbl_book_loans as tbl
on tlb.library_branch_branchid = tbl.book_loans_branchid
group by tlb.library_branch_branchid,tlb.library_branch_branchname
order by total_loan_transactions desc;

   #4.Which library branch has the highest average number of books borrowed per borrower?alter
   
select
 tlb.library_branch_branchname,round(count(tbl.book_loans_loansid) /count(distinct tbl.book_loans_cardno),2) as average_books_per_borrower
from tbl_library_branch as tlb
join tbl_book_loans as tbl
on tlb.library_branch_branchid = tbl.book_loans_branchid
group by tlb.library_branch_branchid,tlb.library_branch_branchname
order by average_books_per_borrower desc;

   #5.Which library branch has the highest number of unique book titles?
   
select tlb.library_branch_branchname,count(distinct tbc.book_copies_bookid) as unique_book_titles
from tbl_library_branch as tlb
join tbl_book_copies as tbc
on tlb.library_branch_branchid = tbc.book_copies_branchid
group by tlb.library_branch_branchid,tlb.library_branch_branchname
order by unique_book_titles desc;

#Module 4 – Loan Analytics

    #1. For each book that is loaned out from the "Sharpstown" branch and whoseDueDate is 2/3/18, retrieve the book title, the borrower's name, and theborrower's address
select tb.book_title,tbo.borrower_borrowername,tbo.borrower_borroweraddress from tbl_book_loans as tbl
join tbl_book as tb
on tbl.book_loans_bookid=tb.book_bookid
join tbl_library_branch as tlb
on tbl.book_loans_branchid=tlb.library_branch_branchid
join tbl_borrower as tbo
on tbl.book_loans_cardno=tbo.borrower_cardno
where tlb.library_branch_branchname='sharpstown' and tbl.book_loans_duedate='2018-02-03';

   #2.Which books have been borrowed the most in each library branch?

WITH book_borrowing AS (
    SELECT tlb.library_branch_branchname,tb.book_title,COUNT(tbl.book_loans_loansid) AS total_borrowed,
        RANK() OVER (
            PARTITION BY tlb.library_branch_branchid 
            ORDER BY COUNT(tbl.book_loans_loansid) DESC
        ) AS rnk
    FROM tbl_book_loans AS tbl
    JOIN tbl_book AS tb
	ON tbl.book_loans_bookid = tb.book_bookid
    JOIN tbl_library_branch AS tlb
	ON tbl.book_loans_branchid = tlb.library_branch_branchid
    GROUP BY tlb.library_branch_branchid,tlb.library_branch_branchname,tb.book_bookid,tb.book_title
)
SELECT library_branch_branchname,book_title,total_borrowed
FROM book_borrowing
WHERE rnk = 1
ORDER BY library_branch_branchname;

   #3.Which borrowers currently have the highest number of books checked out?
   
select tbo.borrower_borrowername,tbo.borrower_borroweraddress,count(tbl.book_loans_loansid) as books_checked_out
from tbl_borrower as tbo
join tbl_book_loans as tbl
on tbo.borrower_cardno = tbl.book_loans_cardno
group by tbo.borrower_cardno,tbo.borrower_borrowername,tbo.borrower_borroweraddress
order by books_checked_out desc;


#Module 5 – Publisher Analytics

   #1.Which publishers have the highest number of books available in the library?

select tp.publisher_publishername,count(tb.book_bookid) as total_books
from tbl_publisher as tp
join tbl_book as tb
on tp.publisher_publishername = tb.book_publishername
group by tp.publisher_publishername
order by total_books desc;

   #2.Which publisher owns the highest number of book copies across all library branches?
  
select tp.publisher_publishername,sum(tbc.book_copies_no_of_copies) as total_book_copies
from tbl_publisher as tp
join tbl_book as tb
on tp.publisher_publishername = tb.book_publishername
join tbl_book_copies as tbc
on tb.book_bookid = tbc.book_copies_bookid
group by tp.publisher_publishername
order by total_book_copies desc;


   

