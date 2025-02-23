-- MARIADB MOCKUP DATA

-- Tabella users
INSERT INTO users (username, email, password_hash, created_at, status)
VALUES 
  ('john_doe', 'john@example.com', 'hash_password_1', CURRENT_TIMESTAMP, 'active'),
  ('jane_doe', 'jane@example.com', 'hash_password_2', CURRENT_TIMESTAMP, 'active'),
  ('inactive_user', 'inactive@example.com', 'hash_password_3', CURRENT_TIMESTAMP, 'inactive');

-- Tabella roles
INSERT INTO roles (name, description, created_at)
VALUES
  ('admin', 'Administrator with full access', CURRENT_TIMESTAMP),
  ('editor', 'Can edit content', CURRENT_TIMESTAMP),
  ('viewer', 'Can view content only', CURRENT_TIMESTAMP);

-- Tabella capabilities
INSERT INTO capabilities (name, description, created_at)
VALUES
  ('manage_users', 'Manage user accounts', CURRENT_TIMESTAMP),
  ('edit_content', 'Edit content in the platform', CURRENT_TIMESTAMP),
  ('view_content', 'View content only', CURRENT_TIMESTAMP),
  ('delete_content', 'Delete content from the platform', CURRENT_TIMESTAMP);

-- Tabella user_roles
INSERT INTO user_roles (user_id, role_id, assigned_at)
VALUES
  (1, 1, CURRENT_TIMESTAMP),
  (2, 2, CURRENT_TIMESTAMP),
  (3, 3, CURRENT_TIMESTAMP);

-- Tabella role_capabilities
INSERT INTO role_capabilities (role_id, capability_id, assigned_at)
VALUES
  (1, 1, CURRENT_TIMESTAMP),
  (1, 2, CURRENT_TIMESTAMP),
  (1, 3, CURRENT_TIMESTAMP),
  (1, 4, CURRENT_TIMESTAMP),
  (2, 2, CURRENT_TIMESTAMP),
  (2, 3, CURRENT_TIMESTAMP),
  (3, 3, CURRENT_TIMESTAMP);
