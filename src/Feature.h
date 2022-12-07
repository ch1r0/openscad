#pragma once

#include <cstdio>
#include <iostream>
#include <string>
#include <map>
#include <vector>

#include "exceptions.h"

class Feature
{
public:
  using list_t = std::vector<Feature *>;
  using iterator = list_t::iterator;

  static const Feature ExperimentalFastCsg;
  static const Feature ExperimentalFastCsgTrustCorefinement;
  static const Feature ExperimentalFastCsgDebug;
  static const Feature ExperimentalFastCsgExact;
  static const Feature ExperimentalFastCsgExactCorefinementCallback;
  static const Feature ExperimentalFastCsgRemesh;
  static const Feature ExperimentalFastCsgRemeshPredictibly;
  static const Feature ExperimentalRoof;
  static const Feature ExperimentalInputDriverDBus;
  static const Feature ExperimentalLazyUnion;
  static const Feature ExperimentalVxORenderers;
  static const Feature ExperimentalVxORenderersIndexing;
  static const Feature ExperimentalVxORenderersDirect;
  static const Feature ExperimentalVxORenderersPrealloc;
  static const Feature ExperimentalTextMetricsFunctions;
  static const Feature ExperimentalImportFunction;
  static const Feature ExperimentalSortStl;

  const std::string& get_name() const;
  const std::string& get_description() const;

  bool is_enabled() const;
  void enable(bool status);

  static iterator begin();
  static iterator end();

  static std::string features();
  static void enable_feature(const std::string& feature_name, bool status = true);
  static void enable_all(bool status = true);

private:
  bool enabled;

  const std::string name;
  const std::string description;

  using map_t = std::map<std::string, Feature *>;
  static map_t feature_map;
  static list_t feature_list;

  Feature(const std::string& name, const std::string& description);
  virtual ~Feature();
};

class ExperimentalFeatureException : public EvaluationException
{
public:
  static void check(const Feature& feature);
  ~ExperimentalFeatureException() noexcept = default;

private:
  ExperimentalFeatureException(const std::string& what_arg);
};
