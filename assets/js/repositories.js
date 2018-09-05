import React from 'react';
import { List, Datagrid, TextField, Button } from 'react-admin';

const Github = ({record, source}) => {
  let repo = record[source];
  return <Button href={`https://github.com/${repo}`} target="_blank">{repo}</Button>;
}

export const RepositoryList = (props) => (
  <List {...props}>
    <Datagrid>
      {/* <TextField source="id" /> */}
      <Github source="github" />
    </Datagrid>
  </List>
);
