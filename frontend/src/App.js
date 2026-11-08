import React, { useState, useEffect } from 'react';
import api from './api';

function App() {
  const [tasks, setTasks] = useState([]);
  const [newTitle, setNewTitle] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  useEffect(() => {
    fetchTasks();
  }, []);

  const fetchTasks = async () => {
    setLoading(true);
    try {
      const res = await api.get("/tasks");
      setTasks(res.data);
      setError(null);
    } catch (err) {
      console.error("Error fetching tasks:", err);
      setError("Lỗi kết nối server: Không thể tải danh sách công việc.");
    } finally {
      setLoading(false);
    }
  };

  const addTask = async (e) => {
    e.preventDefault();
    if (!newTitle.trim()) return;
    try {
      await api.post("/tasks", { title: newTitle, description: "", status: false });
      setNewTitle("");
      setError(null);
      fetchTasks();
    } catch (err) {
      console.error("Error adding task:", err);
      setError("Không thể thêm task. Vui lòng kiểm tra kết nối server.");
    }
  };

  const toggleTask = async (task) => {
    try {
      await api.put(`/tasks/${task.id}`, { ...task, status: !task.status });
      fetchTasks();
      setError(null);
    } catch (err) {
      console.error("Error updating task:", err);
      setError("Không thể cập nhật trạng thái công việc.");
    }
  };

  const deleteTask = async (id) => {
    try {
      await api.delete(`/tasks/${id}`);
      setError(null);
      fetchTasks();
    } catch (err) {
      console.error("Error deleting task:", err);
      setError("Không thể xóa công việc.");
    }
  };

  return (
    <div style={{ 
      maxWidth: '500px', 
      margin: '50px auto', 
      padding: '20px', 
      fontFamily: 'Arial, sans-serif',
      boxShadow: '0 4px 6px rgba(0,0,0,0.1)',
      borderRadius: '8px',
      backgroundColor: '#f9f9f9'
    }}>
      <h1 style={{ textAlign: 'center', color: '#333' }}>My Tasks</h1>
      
      <form onSubmit={addTask} style={{ display: 'flex', gap: '10px', marginBottom: '20px' }}>
        <input 
          style={{ 
            flex: 1, 
            padding: '10px', 
            borderRadius: '4px', 
            border: '1px solid #ddd' 
          }}
          value={newTitle} 
          onChange={(e) => setNewTitle(e.target.value)} 
          placeholder="New task..."
        />
        <button type="submit" style={{ 
          padding: '10px 20px', 
          backgroundColor: '#28a745', 
          color: 'white', 
          border: 'none', 
          borderRadius: '4px', 
          cursor: 'pointer' 
        }}>Add</button>
      </form>

      {error && <p style={{ color: 'red' }}>{error}</p>}
      
      {loading ? (
        <p style={{ textAlign: 'center' }}>Loading tasks...</p>
      ) : (
        <ul style={{ listStyle: 'none', padding: 0 }}>
          {tasks.length === 0 && !error && <p style={{ textAlign: 'center', color: '#888' }}>No tasks yet!</p>}
          {tasks.map(task => (
            <li key={task.id} style={{ 
              display: 'flex', 
              alignItems: 'center', 
              padding: '10px', 
              borderBottom: '1px solid #eee',
              gap: '10px'
            }}>
            <input 
              type="checkbox" 
              checked={task.status} 
              onChange={() => toggleTask(task)} 
            />
            <span style={{ 
              flex: 1, 
              textDecoration: task.status ? 'line-through' : 'none',
              color: task.status ? '#888' : '#333'
            }}>
              {task.title}
            </span>
            <button 
              onClick={() => deleteTask(task.id)}
              style={{ color: '#dc3545', border: 'none', background: 'none', cursor: 'pointer' }}
            >Delete</button>
          </li>
          ))}
        </ul>
      )}
    </div>
  );
}

export default App;
