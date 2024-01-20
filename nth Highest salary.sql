-- how to find nth highest salary in sql server 

select distinct top 1 first_name,last_name,salary from dbo.employees
order by salary DESC

---using sub-query

select first_name,last_name,salary from dbo.employees
where Salary = (select max(salary)from dbo.employees)

--using CTE
with Maxsalary as
(
select first_name,last_name,salary from dbo.employees
where Salary = (select max(salary)from dbo.employees)
)
select * from Maxsalary

--find the 2nd,3rd,15th highest
with myname as
(
select salary,DENSE_RANK() over ( order by salary desc) as DenseRank
from dbo.employees
)
select distinct Salary from myname
where DENSERANK = 15
