package database;

/**
 * This class handles the connection to the MySQL DB.
 * Implements the DB ConnectorInterface.
 * Please do not use this class to access the DB.
 * 
 * @author Ian Wilhelmsen
 * last updated: 3/19/2020
 */

import java.util.Map;
import java.util.Map.Entry;
import java.util.ArrayList;
import java.util.Collection;
import java.util.LinkedHashMap;
import models.ModelAnnotations;
import models.ModelObject;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.CallableStatement;
import java.lang.annotation.Annotation;
import java.lang.reflect.*;

public class MySQLDBConnectorImpl implements DBConnectorInterface {

	// java sql utilities
	private Connection conn;
	private CallableStatement sql;

	// connection information
	private final String dbmsDriverInfo = "jdbc:mysql:";
	private final String dbmsDriverClass = "com.mysql.jdbc.Driver";
	private final String hostString = "//localhost:3306/";
	private final String dbName = "pizzaposdb";
	private final String urlOptionChar = "?";
	private final String urlConjChar = "&";
	private final String useSSLFalse = "useSSL=false";
	private final String usePublicKeys = "allowPublicKeyRetrieval=true";
	private final String useFieldParamsOpt = "noAccessToProcedureBodies=true";
	private final String disableVerification = "verifyServerCertificate=false";
	private final String userName = "pizzaposuser";
	private final String password = "Burnt4Pizzas!";

	// NOTE: CLASS DEBUG MODE
	// This will give back stubbed values while true
	private final boolean debugMode = false;
	private final boolean devEnvironment = true;

	// SQL CallableStatements Strings for SQL statement creation
	private final String startOfSQLStatement = "{CALL ";
	private final String dbParameterStart = "(";
	private final String sqlParameterPlaceholder = "?,";
	private final String endSQLStatement = "?)}";
	private final String createStoredProcedurePrefix = "create_";
	private final String readStoredProcedurePrefix = "read_";
	private final String updateStoredProcedurePrefix = "update_";
	private final String deleteStoredProcedurePrefix = "delete_";

	// annotation constants
	private final String tableNameAnnotation = DatabaseConstants.TABLE_NAME_ANNOTATION;
	private final String notPrimitiveErrorMessage = "Input was not a primitive";

	// SQL CallableStatements integer Constants
	private final int successValue = 1;
	private final int minIDReturnVal = 0;
	private final int callableStartValue = 1;

	MySQLDBConnectorImpl() {
		// Start the connection.
		try {
			Class.forName(dbmsDriverClass);
			this.connect();
		} catch (ClassNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

	@Override
	/**
	 * This method is the insert call for an object that has a direct match to the
	 * db
	 * 
	 * @param _keyValuePairs   the list of parameters from the object
	 * @param _returnTypeArray the java.sql types to return
	 * @param _class           the desired class.
	 * @return int the ID of the created object
	 */
	public int createObject(LinkedHashMap<String, String> _keyValuePairs, int[] _returnTypeArray, Class<?> _class) {
		// Initialize a response with a default of 0.
		int retVal = 0;
		// This is a stubbed response if the debug mode is on.
		if (this.debugMode) {
			retVal = 42;
		} else {
			try {
				// Drop the id from the keyValuePairs because our inserts stored procedures
				// don't need it.
				_keyValuePairs.remove(DatabaseConstants.DB_ID_VALUE);
				this.prepCallableStatement(_keyValuePairs, _returnTypeArray, this.createStoredProcedurePrefix,
						this.getTableNameFromClass(_class));
				// Grab the number of parameters.
				int numberOfParameters = _keyValuePairs.size() + _returnTypeArray.length;
				// Execute the prepared call.
				this.sql.executeQuery();
				// If this an integer, then prepare to return it to the caller.
				if ((!this.sql.getString(numberOfParameters).isEmpty())
						&& Integer.parseInt(this.sql.getString(numberOfParameters)) > this.minIDReturnVal) {
					// Set the return value to the ID that was returned from the DB.
					retVal = Integer.parseInt(this.sql.getString(numberOfParameters));
				}
				// If there was an issue, the exception here catches the error.
			} catch (SQLException e) {
				// TODO Auto-generated catch block.
				e.printStackTrace();
			}
		}
		// Return the value to the caller.
		return retVal;
	}

	@Override
	/**
	 * This function is a basic get for an object from the database.
	 * 
	 * @param _keyValuePairs   the list of parameters from the object
	 * @param _returnTypeArray the java.sql types to return
	 * @param _class           the desired class.
	 * @return ArrayList<ModelObject> objects pulled from the db.
	 */
	public ArrayList<ModelObject> readObject(LinkedHashMap<String, String> _keyValuePairs, int[] _returnTypeArray,
			Class<?> _class) {
		// Initialize a return value for the caller.
		ArrayList<ModelObject> retVal = new ArrayList<ModelObject>();
		// If we are not in debug mode then proceed.
		if (!debugMode) {
			try {
				// Construct the base call.
				this.prepCallableStatement(_keyValuePairs, _returnTypeArray, this.readStoredProcedurePrefix,
						this.getTableNameFromClass(_class));
				// Initialize the result set as the result of the sql execution.
				ResultSet results = this.sql.executeQuery();
				// Spin through the result set while there are still values.
				while (results.next()) {
					// Create a new instance of the class.
					ModelObject resultObject = this.fillOutObject(results, _class);
					retVal.add(resultObject);
				}
			} catch (SQLException | InstantiationException | IllegalAccessException | IllegalArgumentException
					| InvocationTargetException | NoSuchMethodException | SecurityException
					| ClassNotFoundException e) {
				// TODO find a common solution for this
				e.printStackTrace();
			}
		}
		// return the value to the caller
		return retVal;
	}

	@Override
	/**
	 * This function is an update function for an object in the database.
	 * 
	 * @param _keyValuePairs   the list of parameters from the object
	 * @param _returnTypeArray the java.sql types to return
	 * @param _class           the desired class.
	 * @return boolean: Returns true if call was successful.
	 */
	public boolean updateObject(LinkedHashMap<String, String> _keyValuePairs, int[] _returnTypeArray, String _uuid,
			Class<?> _class) {
		// Initialize a return value and default FALSE.
		boolean retVal = false;

		// If debug is on then bypass all of this.
		if (!debugMode) {
			// Prepare the call in a try catch block.
			try {
				this.prepCallableStatement(_keyValuePairs, _returnTypeArray, this.updateStoredProcedurePrefix,
						this.getTableNameFromClass(_class));
				// Grab the number of parameters.
				int numberOfParameters = _keyValuePairs.size() + _returnTypeArray.length;
				// Execute the statement.
				this.sql.executeQuery();
				// if this is the correct return value then return it as a boolean.
				if ((!this.sql.getString(numberOfParameters).isEmpty())
						&& Integer.parseInt(this.sql.getString(numberOfParameters)) > this.minIDReturnVal) {
					retVal = (Integer.parseInt(this.sql.getString(numberOfParameters)) == this.successValue ? true
							: false);
				}
			} catch (SQLException e) {
				// TODO Auto-generated catch block.
				e.printStackTrace();
			}
		}
		// Return the value to caller.
		return retVal;
	}

	@Override
	/**
	 * This method flags a row in the database as inactive.
	 * 
	 * @param _uuid:  The Unique Universal Identification assigned to the object
	 * @param _table: The string representing the table to look for this row.
	 * 
	 * @return boolean: True if operation successful and false otherwise.
	 */
	public boolean deleteObject(LinkedHashMap<String, String> _keyValuePairs, int[] _returnTypeArray, Class<?> _class) {
		// Initialize a return value and default to FALSE
		boolean retVal = false;
		// If debug is on then bypass all of this.
		if (!debugMode) {
			// Prepare the call in a try catch block.
			try {
				this.prepCallableStatement(_keyValuePairs, _returnTypeArray, this.deleteStoredProcedurePrefix,
						this.getTableNameFromClass(_class));
				// Grab the number of parameters.
				int numberOfParameters = _keyValuePairs.size() + _returnTypeArray.length;
				// Execute the query.
				this.sql.executeQuery();
				// If this is the correct return value then return it as a boolean.
				if ((!this.sql.getString(numberOfParameters).isEmpty())
						&& Integer.parseInt(this.sql.getString(numberOfParameters)) > this.minIDReturnVal) {
					retVal = (Integer.parseInt(this.sql.getString(numberOfParameters)) == this.successValue ? true
							: false);
				}
			} catch (SQLException e) {
				// TODO Auto-generated catch block.
				e.printStackTrace();
			}
		}
		// Return the value to the caller.
		return retVal;
	}

	/**
	 * This is a broiler plate helper method to create the callable statement.
	 * 
	 * @param _keyValuePairs
	 * @param _returnTypeArray
	 * @param _storedProcedurePrefix
	 * @param _tableName
	 */
	private void prepCallableStatement(Map<String, String> _keyValuePairs, int[] _returnTypeArray,
			String _storedProcedurePrefix, String _tableName) {
		int numberOfParameters = _keyValuePairs.size() + _returnTypeArray.length;
		try {
			// Construct the base call.
			this.sql = this.conn.prepareCall(
					this.makeSQLPreparedCallString(_storedProcedurePrefix + _tableName, numberOfParameters));
			// update the call with the parameters
			this.assembleCallableStatement(_keyValuePairs);
			this.custRegisterOutParameters(numberOfParameters, _keyValuePairs.size(), _returnTypeArray);
		} catch (SQLException e) {
			e.printStackTrace();
		}
	}

	/**
	 * This method assembles the callable statement from the key value pairs
	 * 
	 * @param _keyValuePairs The key value pairs from the attributes of the class
	 */
	private void assembleCallableStatement(Map<String, String> _keyValuePairs) {
		// spin through the map and populate the call
		// REMEMBER: this SQL library call starts iterating at one.
		// Start a counter
		int index = this.callableStartValue;
		// spin through the key value pairs
		for (Entry<String, String> keyValuePair : _keyValuePairs.entrySet()) {
			// add in the parameter in a try catch
			try {
				if (index <= _keyValuePairs.size() + 1) {
					// Adding in the value for the call
					this.sql.setString(index, keyValuePair.getValue());
				}
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			// update the counter
			index++;
		}
	}

	/**
	 * This method creates the inital arguement for a callable statement. The
	 * CallableStatement in the java.sql library requires a string encapsulated by
	 * braces, with a keyword 'call', the stored procedure name, a number of comma
	 * separated ?'s corresponding to the number of input parameters.
	 * 
	 * @param _sqlStoredProcedureName This is the store procedure name
	 * @param _numberOfParameters     this is the number of parameters of that
	 *                                stored procedure
	 * @return String the finalized string for the callable procedure.
	 */
	private String makeSQLPreparedCallString(String _sqlStoredProcedureName, int _numberOfParameters) {
		// initiate a return value as a string builder
		String retVal = this.startOfSQLStatement + _sqlStoredProcedureName + this.dbParameterStart;
		for (int i = 1; i < _numberOfParameters; i++) {
			// add a on a placeholder
			retVal = retVal.concat(this.sqlParameterPlaceholder);
		}
		retVal = retVal.concat(this.endSQLStatement);
		return retVal;
	}

	/**
	 * This function automatically registers the outputs with data type.
	 * 
	 * @param _numberOfParameters: The number of parameters expected in the stored
	 *                             procedure call.
	 * @param _keyValuePairs:      The number of parameters being passed.
	 * @param _typesToReturn:      A string array of data types desired for each
	 *                             output parameter IN ORDER.
	 */
	@SuppressWarnings("null")
	private void custRegisterOutParameters(int _numberOfParameters, int _numberOfKeyValuePairs, int[] _typesToReturn) {
		// This is a sql contruct, surround this with a try catch block
		try {
			// If there is a difference in the length of the parameters needed for the call
			// and the number of parameters requested then register those.
			if (_numberOfParameters != _numberOfKeyValuePairs
					&& (_typesToReturn != null || _typesToReturn.length != 0)) {
				// Initialize a number of parametes needed.
				int numberOfParametersNeeded = _numberOfParameters - _numberOfKeyValuePairs;
				// For the number of parameters needed, register that index as an out.
				for (int i = 1; i <= numberOfParametersNeeded; i++) {
					this.sql.registerOutParameter(i + _numberOfKeyValuePairs, _typesToReturn[(i - 1)]);
				}
			}
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

	/**
	 * This function gets the table name from the class by reflection.
	 * 
	 * @param _class
	 * @return the table name
	 */
	private String getTableNameFromClass(Class<?> _class) {
		// Initialize a return value for the caller.
		String retVal = null;
		// Grab the annotations from the class.
		Annotation[] classAnnotations = _class.getAnnotations();
		// Find the table name by the key.
		for (Annotation annotation : classAnnotations) {
			// If this is the table name key, grab the value.
			if (annotation instanceof ModelAnnotations
					&& ((ModelAnnotations) annotation).key().equals(this.tableNameAnnotation)) {
				retVal = ((ModelAnnotations) annotation).value();
				break;
			}
		}
		// Return the final value to the caller
		return retVal;
	}

	/**
	 * This method creates an instance of a target Model Object.
	 * 
	 * @param _targetClass
	 * @return
	 * @throws ClassNotFoundException
	 * @throws InstantiationException
	 * @throws IllegalAccessException
	 * @throws IllegalArgumentException
	 * @throws InvocationTargetException
	 * @throws NoSuchMethodException
	 * @throws SecurityException
	 */
	private ModelObject makeModelObject(Class<?> _targetClass)
			throws ClassNotFoundException, InstantiationException, IllegalAccessException, IllegalArgumentException,
			InvocationTargetException, NoSuchMethodException, SecurityException {
		ModelObject retVal = (ModelObject) _targetClass.getConstructor().newInstance();
		return (ModelObject) _targetClass.cast(retVal);
	}

	/**
	 * This method fills up the object with results from the db.
	 * 
	 * @param _results:      The ResultSet from the DB.
	 * @param _targetObject: The object to fill up from the ResultSet.
	 * @throws IllegalArgumentException
	 * @throws IllegalAccessException
	 * @throws SQLException
	 * @throws SecurityException
	 * @throws NoSuchMethodException
	 * @throws InvocationTargetException
	 * @throws InstantiationException
	 * @throws ClassNotFoundException
	 */
	private ModelObject fillOutObject(ResultSet _results, Class<?> _targetClass)
			throws IllegalArgumentException, IllegalAccessException, SQLException, ClassNotFoundException,
			InstantiationException, InvocationTargetException, NoSuchMethodException, SecurityException {
		// Create a return value for the method
		ModelObject retVal = this.makeModelObject(_targetClass);
		Class<?> currObject = _targetClass;
		while (!currObject.getName().equals(DatabaseConstants.TARGET_SUPER_CLASS)) {
			// Loop through each field in the target class and fill in the fields
			for (Field currField : currObject.getDeclaredFields()) {
				if (!Collection.class.isAssignableFrom(currField.getType())) {
					// Use this to change the access of the field to public for this instance.
					currField.setAccessible(true);
					// Grab the field annotation from the field.
					String colName = retVal.findValueFromFieldColumnDBAnnotation(currField);
					Object value = _results.getObject(colName);
					// Type cast all of the pieces.
					Class<?> type = currField.getType();
					if (this.checkPrimitiveType(type)) {
						Class<?> typeToCast = this.getCastTypeForField(type);
						if (type.equals(boolean.class)) {
							currField.setBoolean(retVal, (this.successValue == Integer.class.cast(value)));
							continue;
						} else {
							value = typeToCast.cast(value);
						}
					}
					// Fill the object up with all the values.
					currField.set(retVal, value);
				}
			}
			// Traverse up to the parent class.
			currObject = currObject.getSuperclass();
		}
		return retVal;
	}

	/**
	 * Method checks the type supplied.
	 * 
	 * @param type: The type to check.
	 * @return boolean: Returns if the type is is a primitive that we need to cast.
	 */
	private boolean checkPrimitiveType(Class<?> type) {
		return (type == int.class || type == long.class || type == double.class || type == float.class
				|| type == boolean.class || type == byte.class || type == char.class || type == short.class);
	}

	/**
	 * This method translates the primitive types for the object casts.
	 * 
	 * @param type: The input type to translate.
	 * @return Class: The return is the target cast for consumption.
	 */
	private Class<?> getCastTypeForField(Class<?> _type) {
		if (_type == int.class) {
			return Integer.class;
		} else if (_type == long.class) {
			return Long.class;
		} else if (_type == double.class) {
			return Double.class;
		} else if (_type == float.class) {
			return Float.class;
		} else if (_type == boolean.class) {
			return Boolean.class;
		} else if (_type == byte.class) {
			return Byte.class;
		} else if (_type == char.class) {
			return Character.class;
		} else if (_type == short.class) {
			return Short.class;
		} else {
			throw new IllegalArgumentException(this.notPrimitiveErrorMessage);
		}
	}

	/**
	 * Basic connection method to connect to the db.
	 */
	private void connect() {
		try {
			// Connect to the Database. This is a long and involved. The first connection
			// string is for a dev environment only
			if (this.devEnvironment) {
				this.conn = DriverManager.getConnection(
						this.dbmsDriverInfo + this.hostString + this.dbName + this.urlOptionChar
								+ this.disableVerification + this.urlConjChar + this.useSSLFalse + this.urlConjChar
								+ this.usePublicKeys + this.urlConjChar + this.useFieldParamsOpt,
						this.userName, this.password);
			} else {
				// TODO this needs to be evaluated on a case by case basis for new arguments
				// in production.
			}
		} catch (SQLException e) {
			// TODO goto to logging or create an error report system
			e.printStackTrace();
		}
	}
}