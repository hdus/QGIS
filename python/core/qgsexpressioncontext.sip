/** \ingroup core
 * \class QgsScopedExpressionFunction
 * \brief Expression function for use within a QgsExpressionContextScope. This differs from a
 * standard QgsExpression::Function in that it requires an implemented
 * clone() method.
 * \note added in QGIS 2.12
 */

class QgsScopedExpressionFunction : QgsExpression::Function
{
%TypeHeaderCode
#include <qgsexpressioncontext.h>
%End
  public:
    QgsScopedExpressionFunction( const QString& fnname,
                                 int params,
                                 const QString& group,
                                 const QString& helpText = QString(),
                                 bool usesGeometry = false,
                                 const QSet<QString>& referencedColumns = QSet<QString>(),
                                 bool lazyEval = false,
                                 bool handlesNull = false,
                                 bool isContextual = true );

    /**
     * Create a new QgsScopedExpressionFunction using named parameters.
     *
     * @note Added in QGIS 3.0
     */
    QgsScopedExpressionFunction( const QString& fnname,
                                 const QgsExpression::ParameterList& params,
                                 const QString& group,
                                 const QString& helpText = QString(),
                                 bool usesGeometry = false,
                                 const QSet<QString>& referencedColumns = QSet<QString>(),
                                 bool lazyEval = false,
                                 bool handlesNull = false,
                                 bool isContextual = true );

    virtual ~QgsScopedExpressionFunction();

    virtual QVariant func( const QVariantList& values, const QgsExpressionContext* context, QgsExpression* parent ) = 0;

    /** Returns a clone of the function.
     */
    virtual QgsScopedExpressionFunction* clone() const = 0 /Factory/;

};


/** \ingroup core
 * \class QgsExpressionContextScope
 * \brief Single scope for storing variables and functions for use within a QgsExpressionContext.
 * Examples include a project's scope, which could contain information about the current project such as
 * the project file's location. QgsExpressionContextScope can encapsulate both variables (static values)
 * and functions(which are calculated only when an expression is evaluated).
 *
 * See QgsExpressionContextUtils for helper methods for working with QgsExpressionContextScope objects.
 *
 * \note added in QGIS 2.12
 */

class QgsExpressionContextScope
{
%TypeHeaderCode
#include <qgsexpressioncontext.h>
%End
  public:

    /** Single variable definition for use within a QgsExpressionContextScope.
     */
    struct StaticVariable
    {
      /** Constructor for StaticVariable.
       * @param name variable name (should be unique within the QgsExpressionContextScope)
       * @param value intial variable value
       * @param readOnly true if variable should not be editable by users
       */
      StaticVariable( const QString& name = QString(), const QVariant& value = QVariant(), bool readOnly = false );

      /** Variable name */
      QString name;

      /** Variable value */
      QVariant value;

      /** True if variable should not be editable by users */
      bool readOnly;
    };

    /** Constructor for QgsExpressionContextScope
     * @param name friendly display name for the context scope
     */
    QgsExpressionContextScope( const QString& name = QString() );

    /** Copy constructor
     */
    QgsExpressionContextScope( const QgsExpressionContextScope& other );

    ~QgsExpressionContextScope();

    /** Returns the friendly display name of the context scope.
     */
    QString name() const;

    /** Convenience method for setting a variable in the context scope by name and value. If a variable
     * with the same name is already set then its value is overwritten, otherwise a new variable is added to the scope.
     * @param name variable name
     * @param value variable value
     * @see addVariable()
     */
    void setVariable( const QString& name, const QVariant& value );

    /** Adds a variable into the context scope. If a variable with the same name is already set then its
     * value is overwritten, otherwise a new variable is added to the scope.
     * @param variable definition of variable to insert
     * @see setVariable()
     * @see addFunction()
     */
    void addVariable( const QgsExpressionContextScope::StaticVariable& variable );

    /** Removes a variable from the context scope, if found.
     * @param name name of variable to remove
     * @returns true if variable was removed from the scope, false if matching variable was not
     * found within the scope
     */
    bool removeVariable( const QString& name );

    /** Tests whether a variable with the specified name exists in the scope.
     * @param name variable name
     * @returns true if matching variable was found in the scope
     * @see variable()
     * @see hasFunction()
     */
    bool hasVariable( const QString& name ) const;

    /** Retrieves a variable's value from the scope.
     * @param name variable name
     * @returns variable value, or invalid QVariant if matching variable could not be found
     * @see hasVariable()
     * @see function()
     */
    QVariant variable( const QString& name ) const;

    /** Returns a list of variable names contained within the scope.
     * @see functionNames()
     * @see filteredVariableNames()
     */
    QStringList variableNames() const;

    /** Returns a fitlered and sorted list of variable names contained within the scope.
     * Hidden variable names will be excluded, and the list will be sorted so that
     * read only variables are listed first.
     * @see variableNames()
     */
    QStringList filteredVariableNames() const;

    /** Tests whether the specified variable is read only and should not be editable
     * by users.
     * @param name variable name
     * @returns true if variable is read only
     */
    bool isReadOnly( const QString& name ) const;

    /** Returns the count of variables contained within the scope.
     */
    int variableCount() const;

    /** Tests whether a function with the specified name exists in the scope.
     * @param name function name
     * @returns true if matching function was found in the scope
     * @see function()
     * @see hasFunction()
     */
    bool hasFunction( const QString &name ) const;

    /** Retrieves a function from the scope.
     * @param name function name
     * @returns function, or null if matching function could not be found
     * @see hasFunction()
     * @see functionNames()
     * @see variable()
     */
    QgsExpression::Function* function( const QString &name ) const;

    /** Retrieves a list of names of functions contained in the scope.
     * @see function()
     * @see variableNames()
     */
    QStringList functionNames() const;

    /** Adds a function to the scope.
     * @param name function name
     * @param function function to insert. Ownership is transferred to the scope.
     * @see addVariable()
     */
    void addFunction( const QString& name, QgsScopedExpressionFunction* function /Transfer/ );

    /** Convenience function for setting a feature for the scope. Any existing
     * feature set by the scope will be overwritten.
     * @param feature feature for scope
     */
    void setFeature( const QgsFeature& feature );

    /** Convenience function for setting a fields for the scope. Any existing
     * fields set by the scope will be overwritten.
     * @param fields fields for scope
     */
    void setFields( const QgsFields& fields );
};


/** \ingroup core
 * \class QgsExpressionContext
 * \brief Expression contexts are used to encapsulate the parameters around which a QgsExpression should
 * be evaluated. QgsExpressions can then utilise the information stored within a context to contextualise
 * their evaluated result. A QgsExpressionContext consists of a stack of QgsExpressionContextScope objects,
 * where scopes added later to the stack will override conflicting variables and functions from scopes
 * lower in the stack.
 *
 * See QgsExpressionContextUtils for helper methods for working with QgsExpressionContext objects.
 *
 * \note added in QGIS 2.12
 */

class QgsExpressionContext
{
%TypeHeaderCode
#include <qgsexpressioncontext.h>
%End
  public:

    QgsExpressionContext();

    /** Initializes the context with given list of scopes.
     * Ownership of the scopes is transferred to the stack.
     * @note added in QGIS 3.0
     */
    explicit QgsExpressionContext( const QList<QgsExpressionContextScope*>& scopes /Transfer/ );

    /** Copy constructor
     */
    QgsExpressionContext( const QgsExpressionContext& other );

    ~QgsExpressionContext();

    /** Check whether a variable is specified by any scope within the context.
     * @param name variable name
     * @returns true if variable is set
     * @see variable()
     * @see variableNames()
     */
    bool hasVariable( const QString& name ) const;

    /** Fetches a matching variable from the context. The variable will be fetched
     * from the last scope contained within the context which has a matching
     * variable set.
     * @param name variable name
     * @returns variable value if matching variable exists in the context, otherwise an invalid QVariant
     * @see hasVariable()
     * @see variableNames()
     */
    QVariant variable( const QString& name ) const;

    /**
     * Returns a map of variable name to value representing all the expression variables
     * contained by the context.
     * @note added in QGIS 3.0
     */
    QVariantMap variablesToMap() const;

    /** Returns true if the specified variable name is intended to be highlighted to the
     * user. This is used by the expression builder to more prominently display the
     * variable.
     * @param name variable name
     * @see setHighlightedVariables()
     */
    bool isHighlightedVariable( const QString& name ) const;

    /** Sets the list of variable names within the context intended to be highlighted to the user. This
     * is used by the expression builder to more prominently display these variables.
     * @param variableNames variable names to highlight
     * @see isHighlightedVariable()
     */
    void setHighlightedVariables( const QStringList& variableNames );

    /** Returns the currently active scope from the context for a specified variable name.
     * As scopes later in the stack override earlier contexts, this will be the last matching
     * scope which contains a matching variable.
     * @param name variable name
     * @returns matching scope containing variable, or null if none found
     */
    QgsExpressionContextScope* activeScopeForVariable( const QString& name );

    /** Returns the currently active scope from the context for a specified variable name.
     * As scopes later in the stack override earlier contexts, this will be the last matching
     * scope which contains a matching variable.
     * @param name variable name
     * @returns matching scope containing variable, or null if none found
     * @note not available in python bindings
     */
    //const QgsExpressionContextScope* activeScopeForVariable( const QString& name ) const;

    /** Returns the scope at the specified index within the context.
     * @param index index of scope
     * @returns matching scope, or null if none found
     * @see lastScope()
     */
    QgsExpressionContextScope* scope( int index );

    /** Returns the last scope added to the context.
     * @see scope()
     */
    QgsExpressionContextScope* lastScope();

    /** Returns a list of scopes contained within the stack.
     * @returns list of pointers to scopes
     */
    QList< QgsExpressionContextScope* > scopes();

    /** Returns the index of the specified scope if it exists within the context.
     * @param scope scope to find
     * @returns index of scope, or -1 if scope was not found within the context.
     */
    int indexOfScope( QgsExpressionContextScope* scope ) const;

    /** Returns the index of the first scope with a matching name within the context.
     * @param scopeName name of scope to find
     * @returns index of scope, or -1 if scope was not found within the context.
     * @note added in QGIS 3.0
     */
    int indexOfScope( const QString& scopeName ) const;

    /** Returns a list of variables names set by all scopes in the context.
     * @returns list of unique variable names
     * @see filteredVariableNames
     * @see functionNames
     * @see hasVariable
     * @see variable
     */
    QStringList variableNames() const;

    /** Returns a filtered list of variables names set by all scopes in the context. The included
     * variables are those which should be seen by users.
     * @returns filtered list of unique variable names
     * @see variableNames
     */
    QStringList filteredVariableNames() const;

    /** Returns whether a variable is read only, and should not be modifiable by users.
     * @param name variable name
     * @returns true if variable is read only. Read only status will be taken from last
     * matching scope which contains a matching variable.
     */
    bool isReadOnly( const QString& name ) const;

    /** Checks whether a specified function is contained in the context.
     * @param name function name
     * @returns true if context provides a matching function
     * @see function
     */
    bool hasFunction( const QString& name ) const;

    /** Retrieves a list of function names contained in the context.
     * @see function()
     * @see variableNames()
     */
    QStringList functionNames() const;

    /** Fetches a matching function from the context. The function will be fetched
     * from the last scope contained within the context which has a matching
     * function set.
     * @param name function name
     * @returns function if contained by the context, otherwise null.
     * @see hasFunction
     */
    QgsExpression::Function* function( const QString& name ) const;

    /** Returns the number of scopes contained in the context.
     */
    int scopeCount() const;

    /** Appends a scope to the end of the context. This scope will override
     * any matching variables or functions provided by existing scopes within the
     * context. Ownership of the scope is transferred to the stack.
     * @param scope expression context to append to context
     */
    void appendScope( QgsExpressionContextScope* scope /Transfer/ );

    /** Appends a list of scopes to the end of the context. This scopes will override
     * any matching variables or functions provided by existing scopes within the
     * context. Ownership of the scopes is transferred to the stack.
     * @param scopes scopes to append to context
     * @note added in QGIS 3.0
     */
    void appendScopes( const QList<QgsExpressionContextScope*>& scopes /Transfer/ );

    /**
     * Removes the last scope from the expression context and return it.
     */
    QgsExpressionContextScope* popScope();

    /** Appends a scope to the end of the context. This scope will override
     * any matching variables or functions provided by existing scopes within the
     * context. Ownership of the scope is transferred to the stack.
     */
    QgsExpressionContext& operator<< ( QgsExpressionContextScope* scope /Transfer/ );

    /** Convenience function for setting a feature for the context. The feature
     * will be set within the last scope of the context, so will override any
     * existing features within the context.
     * @param feature feature for context
     * @see feature()
     */
    void setFeature( const QgsFeature& feature );

    /** Convenience function for retrieving the feature for the context, if set.
     * @see setFeature
     */
    QgsFeature feature() const;

    /** Convenience function for setting a fields for the context. The fields
     * will be set within the last scope of the context, so will override any
     * existing fields within the context.
     * @param fields fields for context
     * @see fields()
     */
    void setFields( const QgsFields& fields );

    /** Convenience function for retrieving the fields for the context, if set.
     * @see setFields
     */
    QgsFields fields() const;

    /** Sets the original value variable value for the context.
     * @param value value for original value variable. This usually represents the an original widget
     * value before any data defined overrides have been applied.
     * @note added in QGIS 2.12
     */
    void setOriginalValueVariable( const QVariant& value );

    /** Sets a value to cache within the expression context. This can be used to cache the results
     * of expensive expression sub-calculations, to speed up future evaluations using the same
     * expression context.
     * @param key unique key for retrieving cached value
     * @param value value to cache
     * @see hasCachedValue()
     * @see cachedValue()
     * @see clearCachedValues()
     * @note added in QGIS 2.16
     */
    void setCachedValue( const QString& key, const QVariant& value ) const;

    /** Returns true if the expression context contains a cached value with a matching key.
     * @param key unique key used to store cached value
     * @see setCachedValue()
     * @see cachedValue()
     * @see clearCachedValues()
     * @note added in QGIS 2.16
     */
    bool hasCachedValue( const QString& key ) const;

    /** Returns the matching cached value, if set. This can be used to retrieve the previously stored results
     * of an expensive expression sub-calculation.
     * @param key unique key used to store cached value
     * @returns matching cached value, or invalid QVariant if not set
     * @see setCachedValue()
     * @see hasCachedValue()
     * @see clearCachedValues()
     * @note added in QGIS 2.16
     */
    QVariant cachedValue( const QString& key ) const;

    /** Clears all cached values from the context.
     * @see setCachedValue()
     * @see hasCachedValue()
     * @see cachedValue()
     * @note added in QGIS 2.16
     */
    void clearCachedValues() const;

    //! Inbuilt variable name for fields storage
    static const QString EXPR_FIELDS;
    //! Inbuilt variable name for feature storage
    static const QString EXPR_FEATURE;
    //! Inbuilt variable name for value original value variable
    static const QString EXPR_ORIGINAL_VALUE;
    //! Inbuilt variable name for symbol color variable
    static const QString EXPR_SYMBOL_COLOR;
    //! Inbuilt variable name for symbol angle variable
    static const QString EXPR_SYMBOL_ANGLE;
    //! Inbuilt variable name for geometry part count variable
    static const QString EXPR_GEOMETRY_PART_COUNT;
    //! Inbuilt variable name for geometry part number variable
    static const QString EXPR_GEOMETRY_PART_NUM;
    //! Inbuilt variable name for cluster size variable
    static const QString EXPR_CLUSTER_SIZE;
    //! Inbuilt variable name for cluster color variable
    static const QString EXPR_CLUSTER_COLOR;
};

/** \ingroup core
 * \class QgsExpressionContextUtils
 * \brief Contains utilities for working with QgsExpressionContext objects, including methods
 * for creating scopes for specific uses (e.g., project scopes, layer scopes).
 * \note added in QGIS 2.12
 */

class QgsExpressionContextUtils
{
%TypeHeaderCode
#include <qgsexpressioncontext.h>
%End
  public:

    /** Creates a new scope which contains variables and functions relating to the global QGIS context.
     * For instance, QGIS version numbers and variables specified through QGIS options.
     * @see setGlobalVariable()
     */
    static QgsExpressionContextScope* globalScope() /Factory/;
    static void setGlobalVariable( const QString& name, const QVariant& value );
    static void setGlobalVariables( const QVariantMap& variables );
    static QgsExpressionContextScope* projectScope( const QgsProject* project ) /Factory/;
    static void setProjectVariable( QgsProject* project, const QString& name, const QVariant& value );
    static void setProjectVariables( QgsProject* project, const QVariantMap& variables );

    /** Creates a new scope which contains variables and functions relating to a QgsMapLayer.
     * For instance, layer name, id and fields.
     */
    static QgsExpressionContextScope* layerScope( const QgsMapLayer *layer ) /Factory/;

    /** Creates a list of three scopes: global, layer's project and layer.
     * @note added in QGIS 3.0
     */
    static QList<QgsExpressionContextScope*> globalProjectLayerScopes( const QgsMapLayer* layer ) /Factory/;

    /** Sets a layer context variable. This variable will be contained within scopes retrieved via
     * layerScope().
     * @param layer map layer
     * @param name variable name
     * @param value variable value
     * @see setLayerVariables()
     * @see layerScope()
     */
    static void setLayerVariable( QgsMapLayer* layer, const QString& name, const QVariant& value );
    static void setLayerVariables( QgsMapLayer* layer, const QVariantMap& variables );

    /** Creates a new scope which contains variables and functions relating to a QgsMapSettings object.
     * For instance, map scale and rotation.
     */
    static QgsExpressionContextScope* mapSettingsScope( const QgsMapSettings &mapSettings ) /Factory/;

    /**
     * Updates a symbol scope related to a QgsSymbol to an expression context.
     * @param symbol symbol to extract properties from
     * @param symbolScope pointer to an existing scope to update
     * @note added in QGIS 2.14
     */
    static QgsExpressionContextScope* updateSymbolScope( const QgsSymbol* symbol, QgsExpressionContextScope* symbolScope = nullptr );

    /** Creates a new scope which contains variables and functions relating to a QgsComposition.
     * For instance, number of pages and page sizes.
     * @param composition source composition
     */
    static QgsExpressionContextScope* compositionScope( const QgsComposition *composition ) /Factory/;

    /** Sets a composition context variable. This variable will be contained within scopes retrieved via
     * compositionScope().
     * @param composition target composition
     * @param name variable name
     * @param value variable value
     * @see setCompositionVariables()
     * @see compositionScope()
     */
    static void setCompositionVariable( QgsComposition* composition, const QString& name, const QVariant& value );
    static void setCompositionVariables( QgsComposition* composition, const QVariantMap& variables );
    static QgsExpressionContextScope* atlasScope( const QgsAtlasComposition* atlas ) /Factory/;
    static QgsExpressionContextScope* composerItemScope( const QgsComposerItem *composerItem ) /Factory/;

    /** Sets a composer item context variable. This variable will be contained within scopes retrieved via
     * composerItemScope().
     * @param composerItem target composer item
     * @param name variable name
     * @param value variable value
     * @see setComposerItemVariables()
     * @see composerItemScope()
     */
    static void setComposerItemVariable( QgsComposerItem* composerItem, const QString& name, const QVariant& value );
    static void setComposerItemVariables( QgsComposerItem* composerItem, const QVariantMap& variables );
    static QgsExpressionContext createFeatureBasedContext( const QgsFeature& feature, const QgsFields& fields );

    /** Registers all known core functions provided by QgsExpressionContextScope objects.
     */
    static void registerContextFunctions();

};

