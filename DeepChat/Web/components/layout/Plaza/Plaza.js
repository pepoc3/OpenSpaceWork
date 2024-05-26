import React, { useEffect, useState } from 'react';
import axios from 'axios';

const Plaza = () => {
  const [users, setUsers] = useState([]);

  useEffect(() => {
    // Fetch logged-in users
    axios.get('/api/loggedInUsers') // Adjust the API endpoint as necessary
      .then(response => setUsers(response.data))
      .catch(error => console.error('Error fetching users:', error));
  }, []);

  return (
    <div className="plaza">
      <h1>Plaza</h1>
      <ul>
        {users.map(user => (
          <li key={user.id}>
            <p>{user.name}</p>
            <p>{user.bio}</p>
            <p>{user.chatPrice} tokens</p>
          </li>
        ))}
      </ul>
    </div>
  );
};

export default Plaza;
