#!/bin/bash

DB_NAME=redmine
DB_USER=redmine
DB_PASSWORD=minered
DB_HOST=smlabs

USER_ID=2
FILE_NAME=redmine.org

MYSQL_COMMAND="mysql -s -r --batch --host $DB_HOST --user $DB_USER --password=$DB_PASSWORD $DB_NAME "

echo "* REDMINE TODOS" > $FILE_NAME

PRJ_QUERY="select p.id, p.name from members m, projects p where m.user_id=$USER_ID and p.id = m.project_id order by p.name;"
echo "$MYSQL_COMMAND $PRJ_QUERY"

echo $PRJ_QUERY > .query
$MYSQL_COMMAND < .query |
while read prj_line
do
    PRJ_ID=`echo $prj_line | awk  '{ print $1 }'`
    PRJ_NAME=`echo $prj_line | awk '{ $1=""; print }'`

    echo "** $PRJ_NAME "  >> $FILE_NAME

    ISSUES_QUERY="select i.id, i.subject from issues i, issue_statuses s where s.id=i.status_id and s.is_closed=0 and i.assigned_to_id=$USER_ID and i.project_id=$PRJ_ID order by created_on desc;"
    echo $ISSUES_QUERY > .query

    $MYSQL_COMMAND < .query |
    while read issue_line
    do
        ISSUE_ID=`echo $issue_line | awk '{ print $1 }'`
        ISSUE_NAME=`echo $issue_line | awk '{ $1=""; print }'` 
        echo "*** TODO $ISSUE_NAME ($ISSUE_ID) " >> $FILE_NAME
    done
    echo  >> $FILE_NAME
done

rm -f .query
rm -f .foo