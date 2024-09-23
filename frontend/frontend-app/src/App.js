import React, { useEffect, useState } from 'react';

function App() {
  const [nodes, setNodes] = useState([]);
  const [error, setError] = useState(null);

  useEffect(() => {
    // Fetch backend URL from environment variable
    const backendUrl = process.env.REACT_APP_BACKEND_URL;

    // Log the backend URL to check if it's being correctly set
    console.log("Backend URL:", backendUrl);

    // Fetch data from the backend's /nodes endpoint
    const fetchData = async () => {
      try {
        console.log(`Fetching from: ${backendUrl}/nodes`);  // Log the URL being used for the fetch
        const response = await fetch(`${backendUrl}/nodes`);
        if (!response.ok) {
          throw new Error(`HTTP error! Status: ${response.status}`);
        }
        const data = await response.json();
        console.log("Nodes data received:", data);  // Log the received data
        setNodes(data);
      } catch (error) {
        console.error("Error fetching nodes:", error.message);  // Log the error
        setError(error.message);
      }
    };

    fetchData();
  }, []);

  return (
    <div className="App">
      <h1>Hello Guardian!!!</h1>
      {error && <p>Error: {error}</p>}
      <div>
        {nodes.length > 0 ? (
          nodes.map((node, index) => (
            <p key={index}>
              Name: {node[0]}, Hostname: {node[1]}
            </p>
          ))
        ) : (
          <p>No nodes available</p>
        )}
      </div>
    </div>
  );
}

export default App;